# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Roles Management", type: :system do
  let!(:admin_user) { create(:user, :super_admin) }

  before { login_as(admin_user, scope: :user) }

  describe "Roles List" do
    let!(:role) { create(:role, name: "Test Role", code: "test_role") }

    it "displays list of roles" do
      visit roles_path

      expect(page).to have_content("Phân quyền").or have_content("Roles")
      expect(page).to have_content(role.name)
    end
  end

  describe "Role Creation" do
    it "allows admin to create a new role" do
      visit new_role_path

      fill_in "role_name", with: "New Custom Role"
      # role_code is auto-generated from name, not a form field

      click_button "Tạo vai trò"

      expect(page).to have_content("thành công").or have_content("New Custom Role")
    end
  end

  describe "Role Edit" do
    let!(:role) { create(:role, name: "Editable Role", code: "editable_role") }

    it "allows admin to edit role" do
      visit edit_role_path(role)

      fill_in "role_name", with: "Updated Role Name"
      click_button "Lưu"

      expect(page).to have_content("thành công").or have_content("Updated Role Name")
    end
  end
end
