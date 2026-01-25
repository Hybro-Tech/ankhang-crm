# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ability, type: :model do
  describe 'Guest (no user)' do
    subject(:ability) { described_class.new(nil) }

    it 'has no permissions' do
      expect(ability.can?(:read, :contacts)).to be false
      expect(ability.can?(:manage, :all)).to be false
    end
  end

  describe 'Super Admin' do
    let(:super_admin_role) { Role.find_or_create_by!(name: 'Super Admin', is_system: true) }
    let(:user) { create(:user) }

    before do
      user.roles << super_admin_role unless user.roles.include?(super_admin_role)
    end

    subject(:ability) { described_class.new(user) }

    it 'can manage all' do
      expect(ability.can?(:manage, :all)).to be true
    end

    it 'can access any resource' do
      expect(ability.can?(:view, :contacts)).to be true
      expect(ability.can?(:manage, :roles)).to be true
      expect(ability.can?(:some_random_action, :some_random_resource)).to be true
    end
  end

  describe 'Role-based permissions' do
    # Use unique test role instead of seeded role
    let(:test_role) { create(:role, name: "TestRole_#{SecureRandom.hex(4)}") }
    let(:contacts_view_perm) { Permission.find_or_create_by!(code: 'contacts.view') { |p| p.name = 'Xem Contact'; p.category = 'Contacts' } }
    let(:contacts_pick_perm) { Permission.find_or_create_by!(code: 'contacts.pick') { |p| p.name = 'Pick Contact'; p.category = 'Contacts' } }
    let(:roles_manage_perm) { Permission.find_or_create_by!(code: 'roles.manage') { |p| p.name = 'Quản lý Role'; p.category = 'Roles' } }
    let(:user) { create(:user) }

    before do
      test_role.permissions << contacts_view_perm unless test_role.permissions.include?(contacts_view_perm)
      test_role.permissions << contacts_pick_perm unless test_role.permissions.include?(contacts_pick_perm)
      user.roles << test_role unless user.roles.include?(test_role)
    end

    subject(:ability) { described_class.new(user) }

    it 'grants permissions from assigned roles' do
      expect(ability.can?(:view, :contacts)).to be true
      expect(ability.can?(:pick, :contacts)).to be true
    end

    it 'denies permissions not in roles' do
      expect(ability.can?(:manage, :roles)).to be false
      expect(ability.can?(:create, :contacts)).to be false
    end
  end

  describe 'User permission overrides' do
    let(:test_role) { create(:role, name: "TestRole_#{SecureRandom.hex(4)}") }
    let(:contacts_view_perm) { Permission.find_or_create_by!(code: 'contacts.view') { |p| p.name = 'Xem Contact'; p.category = 'Contacts' } }
    let(:contacts_edit_perm) { Permission.find_or_create_by!(code: 'contacts.edit') { |p| p.name = 'Sửa Contact'; p.category = 'Contacts' } }
    let(:reports_view_perm) { Permission.find_or_create_by!(code: 'reports.view') { |p| p.name = 'Xem Báo cáo'; p.category = 'Reports' } }
    let(:user) { create(:user) }

    before do
      # Role has contacts.view and contacts.edit
      test_role.permissions << contacts_view_perm unless test_role.permissions.include?(contacts_view_perm)
      test_role.permissions << contacts_edit_perm unless test_role.permissions.include?(contacts_edit_perm)
      user.roles << test_role unless user.roles.include?(test_role)
    end

    context 'with grant override' do
      before do
        # Grant reports.view which role does not have
        user.user_permissions.find_or_create_by!(permission: reports_view_perm) do |up|
          up.granted = true
        end
      end

      subject(:ability) { described_class.new(user) }

      it 'grants additional permissions' do
        expect(ability.can?(:view, :reports)).to be true
      end

      it 'still has role permissions' do
        expect(ability.can?(:view, :contacts)).to be true
      end
    end

    context 'with deny override' do
      before do
        # Deny contacts.edit which role has
        user.user_permissions.find_or_create_by!(permission: contacts_edit_perm) do |up|
          up.granted = false
        end
        # Force update if already exists with different granted value
        up = user.user_permissions.find_by(permission: contacts_edit_perm)
        up.update!(granted: false) if up&.granted?
      end

      subject(:ability) { described_class.new(user) }

      it 'denies specific permissions' do
        expect(ability.can?(:edit, :contacts)).to be false
      end

      it 'still has other role permissions' do
        expect(ability.can?(:view, :contacts)).to be true
      end
    end

    context 'with both grant and deny overrides' do
      before do
        # Grant reports.view
        user.user_permissions.find_or_create_by!(permission: reports_view_perm) do |up|
          up.granted = true
        end
        # Deny contacts.edit
        up = user.user_permissions.find_or_create_by!(permission: contacts_edit_perm)
        up.update!(granted: false)
      end

      subject(:ability) { described_class.new(user) }

      it 'applies both overrides correctly' do
        expect(ability.can?(:view, :reports)).to be true
        expect(ability.can?(:edit, :contacts)).to be false
        expect(ability.can?(:view, :contacts)).to be true
      end
    end
  end

  describe 'Multiple roles' do
    let(:role1) { create(:role, name: "TestRole1_#{SecureRandom.hex(4)}") }
    let(:role2) { create(:role, name: "TestRole2_#{SecureRandom.hex(4)}") }
    let(:contacts_view_perm) { Permission.find_or_create_by!(code: 'contacts.view') { |p| p.name = 'Xem Contact'; p.category = 'Contacts' } }
    let(:contacts_pick_perm) { Permission.find_or_create_by!(code: 'contacts.pick') { |p| p.name = 'Pick Contact'; p.category = 'Contacts' } }
    let(:contacts_edit_perm) { Permission.find_or_create_by!(code: 'contacts.edit') { |p| p.name = 'Sửa Contact'; p.category = 'Contacts' } }
    let(:user) { create(:user) }

    before do
      role1.permissions << contacts_view_perm unless role1.permissions.include?(contacts_view_perm)
      role1.permissions << contacts_pick_perm unless role1.permissions.include?(contacts_pick_perm)
      role2.permissions << contacts_view_perm unless role2.permissions.include?(contacts_view_perm)
      role2.permissions << contacts_edit_perm unless role2.permissions.include?(contacts_edit_perm)
      user.roles << role1 unless user.roles.include?(role1)
      user.roles << role2 unless user.roles.include?(role2)
    end

    subject(:ability) { described_class.new(user) }

    it 'combines permissions from all roles' do
      expect(ability.can?(:view, :contacts)).to be true
      expect(ability.can?(:pick, :contacts)).to be true
      expect(ability.can?(:edit, :contacts)).to be true
    end
  end
end
