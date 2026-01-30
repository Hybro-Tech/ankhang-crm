# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ability, type: :model do
  describe "Guest (no user)" do
    subject(:ability) { described_class.new(nil) }

    it "has no permissions" do
      expect(ability.can?(:read, :contacts)).to be false
      expect(ability.can?(:manage, :all)).to be false
    end
  end

  describe "Super Admin" do
    let(:super_admin_role) do
      Role.find_or_create_by!(name: "Super Admin") do |r|
        r.code = RoleCodes::SUPER_ADMIN
        r.dashboard_type = :admin
        r.is_system = true
      end.tap { |role| role.update!(code: RoleCodes::SUPER_ADMIN) if role.code.blank? }
    end
    let(:user) { create(:user) }

    before do
      user.roles << super_admin_role unless user.roles.include?(super_admin_role)
    end

    subject(:ability) { described_class.new(user) }

    it "can manage all" do
      expect(ability.can?(:manage, :all)).to be true
    end

    it "can access any resource" do
      expect(ability.can?(:view, :contacts)).to be true
      expect(ability.can?(:manage, :roles)).to be true
      expect(ability.can?(:some_random_action, :some_random_resource)).to be true
    end
  end

  describe "Role-based permissions" do
    # Use unique test role instead of seeded role
    let(:test_role) { create(:role, name: "TestRole_#{SecureRandom.hex(4)}") }
    let(:contacts_view_perm) do
      Permission.find_or_create_by!(code: "contacts.view") do |p|
        p.name = "Xem Contact"
        p.category = "Contacts"
      end
    end
    let(:contacts_pick_perm) do
      Permission.find_or_create_by!(code: "contacts.pick") do |p|
        p.name = "Pick Contact"
        p.category = "Contacts"
      end
    end
    let(:roles_manage_perm) do
      Permission.find_or_create_by!(code: "roles.manage") do |p|
        p.name = "Quản lý Role"
        p.category = "Roles"
      end
    end
    let(:user) { create(:user) }

    before do
      test_role.permissions << contacts_view_perm unless test_role.permissions.include?(contacts_view_perm)
      test_role.permissions << contacts_pick_perm unless test_role.permissions.include?(contacts_pick_perm)
      user.roles << test_role unless user.roles.include?(test_role)
    end

    subject(:ability) { described_class.new(user) }

    it "grants permissions from assigned roles" do
      expect(ability.can?(:view, :contacts)).to be true
      expect(ability.can?(:pick, :contacts)).to be true
    end

    it "denies permissions not in roles" do
      expect(ability.can?(:manage, :roles)).to be false
      expect(ability.can?(:create, :contacts)).to be false
    end
  end

  describe "User permission overrides" do
    let(:test_role) { create(:role, name: "TestRole_#{SecureRandom.hex(4)}") }
    let(:contacts_view_perm) do
      Permission.find_or_create_by!(code: "contacts.view") do |p|
        p.name = "Xem Contact"
        p.category = "Contacts"
      end
    end
    let(:contacts_edit_perm) do
      Permission.find_or_create_by!(code: "contacts.edit") do |p|
        p.name = "Sửa Contact"
        p.category = "Contacts"
      end
    end
    let(:reports_view_perm) do
      Permission.find_or_create_by!(code: "reports.view") do |p|
        p.name = "Xem Báo cáo"
        p.category = "Reports"
      end
    end
    let(:user) { create(:user) }

    before do
      # Role has contacts.view and contacts.edit
      test_role.permissions << contacts_view_perm unless test_role.permissions.include?(contacts_view_perm)
      test_role.permissions << contacts_edit_perm unless test_role.permissions.include?(contacts_edit_perm)
      user.roles << test_role unless user.roles.include?(test_role)
    end

    context "with grant override" do
      before do
        # Grant reports.view which role does not have
        user.user_permissions.find_or_create_by!(permission: reports_view_perm) do |up|
          up.granted = true
        end
      end

      subject(:ability) { described_class.new(user) }

      it "grants additional permissions" do
        expect(ability.can?(:view, :reports)).to be true
      end

      it "still has role permissions" do
        expect(ability.can?(:view, :contacts)).to be true
      end
    end

    context "with deny override" do
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

      it "denies specific permissions" do
        expect(ability.can?(:edit, :contacts)).to be false
      end

      it "still has other role permissions" do
        expect(ability.can?(:view, :contacts)).to be true
      end
    end

    context "with both grant and deny overrides" do
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

      it "applies both overrides correctly" do
        expect(ability.can?(:view, :reports)).to be true
        expect(ability.can?(:edit, :contacts)).to be false
        expect(ability.can?(:view, :contacts)).to be true
      end
    end
  end

  describe "Multiple roles" do
    let(:role1) { create(:role, name: "TestRole1_#{SecureRandom.hex(4)}") }
    let(:role2) { create(:role, name: "TestRole2_#{SecureRandom.hex(4)}") }
    let(:contacts_view_perm) do
      Permission.find_or_create_by!(code: "contacts.view") do |p|
        p.name = "Xem Contact"
        p.category = "Contacts"
      end
    end
    let(:contacts_pick_perm) do
      Permission.find_or_create_by!(code: "contacts.pick") do |p|
        p.name = "Pick Contact"
        p.category = "Contacts"
      end
    end
    let(:contacts_edit_perm) do
      Permission.find_or_create_by!(code: "contacts.edit") do |p|
        p.name = "Sửa Contact"
        p.category = "Contacts"
      end
    end
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

    it "combines permissions from all roles" do
      expect(ability.can?(:view, :contacts)).to be true
      expect(ability.can?(:pick, :contacts)).to be true
      expect(ability.can?(:edit, :contacts)).to be true
    end
  end

  # ============================================================================
  # TASK-019: Role-specific Contact permissions per SRS v2 Section 2
  # ============================================================================

  describe "Tổng Đài role - Contact permissions" do
    let(:user) { create(:user) }
    let(:tongdai_role) do
      Role.find_or_create_by!(name: "Tổng Đài") do |r|
        r.description = "Nhân viên tổng đài"
      end
    end

    before do
      # Ensure permissions exist
      Permission.find_or_create_by!(code: "contacts.view") { |p| p.name = "Xem" }
      Permission.find_or_create_by!(code: "contacts.create") { |p| p.name = "Tạo" }
      Permission.find_or_create_by!(code: "contacts.pick") { |p| p.name = "Pick" }
      Permission.find_or_create_by!(code: "contacts.edit") { |p| p.name = "Sửa" }

      # Assign correct permissions to Tổng Đài
      tongdai_role.permissions = Permission.where(code: %w[contacts.view contacts.create])
      user.roles << tongdai_role unless user.roles.include?(tongdai_role)
    end

    subject(:ability) { described_class.new(user) }

    it "CAN view contacts" do
      expect(ability.can?(:view, :contacts)).to be true
    end

    it "CAN create contacts" do
      expect(ability.can?(:create, :contacts)).to be true
    end

    it "CANNOT pick contacts" do
      expect(ability.can?(:pick, :contacts)).to be false
    end

    it "CANNOT edit contacts" do
      expect(ability.can?(:edit, :contacts)).to be false
    end
  end

  describe "Sale role - Contact permissions" do
    let(:user) { create(:user) }
    let(:sale_role) do
      Role.find_or_create_by!(name: "Sale") do |r|
        r.description = "Nhân viên kinh doanh"
      end
    end

    before do
      # Ensure permissions exist
      Permission.find_or_create_by!(code: "contacts.view") { |p| p.name = "Xem" }
      Permission.find_or_create_by!(code: "contacts.create") { |p| p.name = "Tạo" }
      Permission.find_or_create_by!(code: "contacts.pick") { |p| p.name = "Pick" }
      Permission.find_or_create_by!(code: "contacts.edit") { |p| p.name = "Sửa" }
      Permission.find_or_create_by!(code: "contacts.update_status") { |p| p.name = "Cập nhật status" }

      # Assign correct permissions to Sale
      sale_role.permissions = Permission.where(
        code: %w[contacts.view contacts.pick contacts.edit contacts.update_status]
      )
      user.roles << sale_role unless user.roles.include?(sale_role)
    end

    subject(:ability) { described_class.new(user) }

    it "CAN view contacts" do
      expect(ability.can?(:view, :contacts)).to be true
    end

    it "CANNOT create contacts" do
      expect(ability.can?(:create, :contacts)).to be false
    end

    it "CAN pick contacts" do
      expect(ability.can?(:pick, :contacts)).to be true
    end

    it "CAN edit contacts" do
      expect(ability.can?(:edit, :contacts)).to be true
    end

    it "CAN update_status contacts" do
      expect(ability.can?(:update_status, :contacts)).to be true
    end
  end

  describe "CSKH role - Contact permissions" do
    let(:user) { create(:user) }
    let(:cskh_role) do
      Role.find_or_create_by!(name: "CSKH") do |r|
        r.description = "Chăm sóc khách hàng"
      end
    end

    before do
      # Ensure permissions exist
      Permission.find_or_create_by!(code: "contacts.view") { |p| p.name = "Xem" }
      Permission.find_or_create_by!(code: "contacts.create") { |p| p.name = "Tạo" }
      Permission.find_or_create_by!(code: "contacts.pick") { |p| p.name = "Pick" }
      Permission.find_or_create_by!(code: "contacts.edit") { |p| p.name = "Sửa" }
      Permission.find_or_create_by!(code: "contacts.view_failed") { |p| p.name = "Xem failed" }
      Permission.find_or_create_by!(code: "contacts.update_status") { |p| p.name = "Cập nhật status" }

      # Assign correct permissions to CSKH
      cskh_role.permissions = Permission.where(
        code: %w[contacts.view_failed contacts.edit contacts.update_status]
      )
      user.roles << cskh_role unless user.roles.include?(cskh_role)
    end

    subject(:ability) { described_class.new(user) }

    it "CANNOT view all contacts" do
      expect(ability.can?(:view, :contacts)).to be false
    end

    it "CAN view_failed contacts" do
      expect(ability.can?(:view_failed, :contacts)).to be true
    end

    it "CANNOT create contacts" do
      expect(ability.can?(:create, :contacts)).to be false
    end

    it "CAN pick contacts (via edit permission alias)" do
      expect(ability.can?(:pick, :contacts)).to be true
    end

    it "CAN edit contacts" do
      expect(ability.can?(:edit, :contacts)).to be true
    end

    it "CAN update_status contacts" do
      expect(ability.can?(:update_status, :contacts)).to be true
    end
  end
end
