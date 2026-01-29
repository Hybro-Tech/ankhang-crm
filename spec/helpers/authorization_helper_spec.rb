# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthorizationHelper, type: :helper do
  let(:user) { create(:user) }
  # Use unique test role to avoid conflicts with seed data
  let(:test_role) { create(:role, name: "TestRole_#{SecureRandom.hex(4)}") }
  let(:contacts_view_perm) do
    Permission.find_or_create_by!(code: "contacts.view") do |p|
      p.name = "Xem Contact"
      p.category = "Contacts"
    end
  end
  let(:reports_view_perm) do
    Permission.find_or_create_by!(code: "reports.view") do |p|
      p.name = "Xem Báo cáo"
      p.category = "Reports"
    end
  end

  before do
    test_role.permissions << contacts_view_perm unless test_role.permissions.include?(contacts_view_perm)
    user.roles << test_role unless user.roles.include?(test_role)
  end

  describe "#can_access?" do
    context "when user is signed in" do
      before do
        allow(helper).to receive(:current_user).and_return(user)
      end

      it "returns true for permissions user has" do
        expect(helper.can_access?("contacts.view")).to be true
      end

      it "returns false for permissions user lacks" do
        expect(helper.can_access?("reports.view")).to be false
      end
    end

    context "when user is not signed in" do
      before do
        allow(helper).to receive(:current_user).and_return(nil)
      end

      it "returns false" do
        expect(helper.can_access?("contacts.view")).to be false
      end
    end
  end

  describe "#show_menu_item?" do
    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    it "returns true when permission is nil" do
      expect(helper.show_menu_item?(nil)).to be true
    end

    it "returns true when permission is blank" do
      expect(helper.show_menu_item?("")).to be true
    end

    it "returns true when user has permission" do
      expect(helper.show_menu_item?("contacts.view")).to be true
    end

    it "returns false when user lacks permission" do
      expect(helper.show_menu_item?("reports.view")).to be false
    end

    context "when user is not signed in" do
      before do
        allow(helper).to receive(:current_user).and_return(nil)
      end

      it "returns false even without permission_code" do
        expect(helper.show_menu_item?).to be false
      end

      it "returns false with blank permission_code" do
        expect(helper.show_menu_item?(nil)).to be false
        expect(helper.show_menu_item?("")).to be false
      end
    end
  end

  describe "#has_role?" do
    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    it "returns true for assigned role" do
      expect(helper.has_role?(test_role.name)).to be true
    end

    it "returns false for unassigned role" do
      expect(helper.has_role?("Super Admin")).to be false
    end
  end

  describe "#super_admin?" do
    context "when user is Super Admin" do
      let(:super_admin_role) { Role.find_or_create_by!(name: "Super Admin", is_system: true) }

      before do
        user.roles << super_admin_role unless user.roles.include?(super_admin_role)
        allow(helper).to receive(:current_user).and_return(user)
      end

      it "returns true" do
        expect(helper.super_admin?).to be true
      end
    end

    context "when user is not Super Admin" do
      before do
        allow(helper).to receive(:current_user).and_return(user)
      end

      it "returns false" do
        # User only has test_role, not Super Admin
        expect(helper.super_admin?).to be false
      end
    end
  end
end
