# frozen_string_literal: true

require "rails_helper"

# SECURITY-AUDIT: Integration tests for accessible_by SQL generation
RSpec.describe "Ability accessible_by integration", type: :model do
  describe "Contact data-level access" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:team) { create(:team) }

    let!(:own_assigned_contact) { create(:contact, assigned_user: user) }
    let!(:own_created_contact) { create(:contact, creator: user) }
    let!(:team_contact) { create(:contact, :with_team, team: team) }
    let!(:other_contact) { create(:contact, assigned_user: other_user) }

    def grant_permission(user_obj, code)
      perm = Permission.find_or_create_by!(code: code) { |p| p.name = code }
      role = create(:role, name: "TestRole_#{SecureRandom.hex(4)}")
      role.permissions << perm unless role.permissions.include?(perm)
      user_obj.roles << role unless user_obj.roles.include?(role)
    end

    context "with contacts.view_own permission" do
      before { grant_permission(user, "contacts.view_own") }

      it "returns only assigned and created contacts" do
        ability = Ability.new(user.reload)
        accessible = Contact.accessible_by(ability)

        expect(accessible).to include(own_assigned_contact, own_created_contact)
        expect(accessible).not_to include(other_contact)
      end
    end

    context "with contacts.view_team permission" do
      before do
        user.teams << team
        grant_permission(user, "contacts.view_team")
      end

      it "returns team contacts" do
        ability = Ability.new(user.reload)
        accessible = Contact.accessible_by(ability)

        expect(accessible).to include(team_contact)
        expect(accessible).not_to include(other_contact)
      end
    end

    context "with contacts.view_all permission" do
      before { grant_permission(user, "contacts.view_all") }

      it "returns all contacts" do
        ability = Ability.new(user.reload)
        accessible = Contact.accessible_by(ability)

        expect(accessible).to include(own_assigned_contact, own_created_contact, team_contact, other_contact)
      end
    end
  end

  describe "Reassign requests virtual resource" do
    context "Super Admin" do
      let(:user) { create(:user) }
      let(:super_admin_role) do
        Role.find_or_create_by!(code: RoleCodes::SUPER_ADMIN) do |r|
          r.name = "Super Admin"
          r.dashboard_type = :admin
          r.is_system = true
        end
      end

      before { user.roles << super_admin_role }

      it "can manage reassign_requests" do
        ability = Ability.new(user.reload)
        expect(ability.can?(:manage, :reassign_requests)).to be true
        expect(ability.can?(:create, :reassign_requests)).to be true
        expect(ability.can?(:read, :reassign_requests)).to be true
      end
    end

    context "Regular user" do
      let(:user) { create(:user) }
      let(:regular_role) do
        Role.find_or_create_by!(code: "sale_test") do |r|
          r.name = "Sale Test #{SecureRandom.hex(4)}"
          r.dashboard_type = :sale
        end
      end

      before { user.roles << regular_role }

      it "cannot manage reassign_requests" do
        ability = Ability.new(user.reload)
        expect(ability.can?(:manage, :reassign_requests)).to be false
        expect(ability.can?(:create, :reassign_requests)).to be false
      end
    end
  end
end
