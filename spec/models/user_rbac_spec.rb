# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "#super_admin?" do
    let(:super_admin_role) do
      Role.find_or_create_by!(code: Role::SUPER_ADMIN) do |r|
        r.name = "Super Admin"
        r.dashboard_type = :admin
      end
    end

    let(:sale_role) do
      Role.find_or_create_by!(code: Role::SALE) do |r|
        r.name = "Sale"
        r.dashboard_type = :sale
      end
    end

    it "returns true when user has super_admin role" do
      user = create(:user, roles: [super_admin_role])
      expect(user.super_admin?).to be true
    end

    it "returns false when user has other role" do
      user = create(:user, roles: [sale_role])
      expect(user.super_admin?).to be false
    end

    it "returns false when user has no roles" do
      user = create(:user, roles: [])
      expect(user.super_admin?).to be false
    end

    it "uses Role::SUPER_ADMIN constant" do
      expect(Role::SUPER_ADMIN).to eq("super_admin")
    end
  end

  describe "#primary_dashboard_type" do
    let(:admin_role) { create(:role, dashboard_type: :admin) }
    let(:sale_role) { create(:role, dashboard_type: :sale) }
    let(:call_center_role) { create(:role, dashboard_type: :call_center) }

    it "returns first role's dashboard_type ordered by id" do
      user = create(:user, roles: [sale_role])
      expect(user.primary_dashboard_type).to eq("sale")
    end

    it "returns admin when no roles" do
      user = create(:user, roles: [])
      expect(user.primary_dashboard_type).to eq("admin")
    end

    it "returns deterministic result with multiple roles" do
      user = create(:user)
      # Add roles in specific order
      user.roles << admin_role
      user.roles << sale_role
      user.roles << call_center_role

      # Should always return the same result (first by id)
      first_result = user.primary_dashboard_type
      second_result = user.primary_dashboard_type
      expect(first_result).to eq(second_result)
    end
  end

  describe "#sale_staff?" do
    let(:sale_role) { create(:role, dashboard_type: :sale) }
    let(:admin_role) { create(:role, dashboard_type: :admin) }

    it "returns true when user has sale role" do
      user = create(:user, roles: [sale_role])
      expect(user.sale_staff?).to be true
    end

    it "returns false when user has other role" do
      user = create(:user, roles: [admin_role])
      expect(user.sale_staff?).to be false
    end
  end

  describe "#call_center_staff?" do
    let(:call_center_role) { create(:role, dashboard_type: :call_center) }
    let(:sale_role) { create(:role, dashboard_type: :sale) }

    it "returns true when user has call_center role" do
      user = create(:user, roles: [call_center_role])
      expect(user.call_center_staff?).to be true
    end

    it "returns false when user has other role" do
      user = create(:user, roles: [sale_role])
      expect(user.call_center_staff?).to be false
    end
  end

  describe "#cskh_staff?" do
    let(:cskh_role) { create(:role, dashboard_type: :cskh) }
    let(:sale_role) { create(:role, dashboard_type: :sale) }

    it "returns true when user has cskh role" do
      user = create(:user, roles: [cskh_role])
      expect(user.cskh_staff?).to be true
    end

    it "returns false when user has other role" do
      user = create(:user, roles: [sale_role])
      expect(user.cskh_staff?).to be false
    end
  end

  describe "#can_access?" do
    let(:role) { create(:role) }
    let(:permission) { Permission.find_or_create_by!(code: "test.permission", name: "Test", category: "Test") }
    let(:user) { create(:user, roles: [role]) }

    before do
      role.permissions << permission unless role.permissions.include?(permission)
    end

    it "returns true when user has permission" do
      expect(user.can_access?("test.permission")).to be true
    end

    it "returns false when user lacks permission" do
      expect(user.can_access?("other.permission")).to be false
    end
  end
end
