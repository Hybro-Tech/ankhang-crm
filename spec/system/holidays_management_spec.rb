# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Holidays Management", type: :system do
  let(:admin) { create(:user, :super_admin) }

  before do
    login_as(admin, scope: :user)
  end

  describe "CRUD Holidays" do
    it "allows admin to create a holiday" do
      visit holidays_path

      click_link "Thêm ngày nghỉ"
      fill_in "Tên ngày lễ", with: "Test Holiday 2099"
      fill_in "Ngày", with: "2099-12-25"
      fill_in "Mô tả", with: "Christmas"
      click_button "Tạo ngày nghỉ"

      expect(page).to have_content("Tạo ngày nghỉ lễ thành công")
      expect(page).to have_content("Test Holiday 2099")
    end

    it "allows admin to edit a holiday" do
      holiday = create(:holiday, name: "Edit Me Holiday", date: "2099-06-15")

      visit holidays_path(year: 2099)

      # Use data-testid for precise targeting
      within("[data-testid='holiday-item-#{holiday.id}']") do
        find("a").click
      end

      fill_in "Tên ngày lễ", with: "Edited Holiday"
      click_button "Lưu thay đổi"

      expect(page).to have_content("Cập nhật ngày nghỉ lễ thành công")
      expect(page).to have_content("Edited Holiday")
    end

    it "allows admin to delete a holiday" do
      holiday = create(:holiday, name: "Delete Me Holiday", date: "2099-07-20")

      visit holidays_path(year: 2099)

      # Use data-testid for precise targeting
      within("[data-testid='holiday-item-#{holiday.id}']") do
        find("button[type='submit']").click
      end

      expect(page).to have_content("Đã xóa ngày nghỉ lễ")
      expect(page).not_to have_content("Delete Me Holiday")
    end
  end
end
