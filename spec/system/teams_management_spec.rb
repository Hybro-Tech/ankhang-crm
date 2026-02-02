# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teams Management", type: :system do
  let!(:admin) { create(:user, :super_admin, email: "admin_sys@test.com", password: "password123") }

  before do
    login_as(admin, scope: :user)
  end

  describe "Teams CRUD" do
    it "allows creating a new team with members", js: true do
      member = create(:user, name: "Available Member", email: "member@test.com")

      visit teams_path
      click_link "Tạo đội mới", match: :first

      fill_in "Tên Team", with: "New System Team"
      select "Bắc", from: "Vùng / Miền"
      fill_in "Mô tả", with: "Test Description"

      # TomSelect: Click on the input to open dropdown, then select user
      # For TomSelect multi-select, we need to use JS or find the hidden input
      find("#team_user_ids", visible: false).set([member.id])

      click_button "Tạo Team"

      expect(page).to have_content("Tạo đội nhóm thành công")
      expect(page).to have_content("New System Team")
    end

    it "allows editing a team" do
      create(:team, name: "Old Team")

      visit teams_path

      # Click edit on the team row
      within("tr", text: "Old Team") do
        click_link "Sửa"
      end

      fill_in "Tên Team", with: "Updated Team Name"
      click_button "Cập nhật Team"

      expect(page).to have_content("Cập nhật đội nhóm thành công")
      expect(page).to have_content("Updated Team Name")
    end

    it "allows deleting a team" do
      create(:team, name: "Delete Me")

      visit teams_path

      within("tr", text: "Delete Me") do
        click_button "Xóa"
      end

      expect(page).to have_content("Đã xóa đội nhóm")
      expect(page).not_to have_content("Delete Me")
    end
  end
end
