# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Authentication", type: :system do
  let!(:user) { create(:user, email: "test@example.com", password: "password123", username: "testuser") }

  describe "Login" do
    it "allows user to sign in with email" do
      visit new_user_session_path

      fill_in "Email hoặc Username", with: "test@example.com"
      fill_in "user[password]", with: "password123"
      click_button "Đăng nhập"

      expect(page).to have_content("Đăng nhập thành công.")
      # expect(page).to have_current_path(root_path)
    end

    it "allows user to sign in with username" do
      visit new_user_session_path

      fill_in "Email hoặc Username", with: "testuser"
      fill_in "user[password]", with: "password123"
      click_button "Đăng nhập"

      expect(page).to have_content("Đăng nhập thành công.")
    end

    it "rejects invalid credentials" do
      visit new_user_session_path

      fill_in "Email hoặc Username", with: "test@example.com"
      fill_in "user[password]", with: "wrongpassword"
      click_button "Đăng nhập"

      expect(page).to have_content("Email hoặc mật khẩu không đúng.")
    end
  end

  describe "Forgot Password" do
    it "sends reset password instructions" do
      visit new_user_session_path
      click_link "Quên mật khẩu?"

      expect(page).to have_current_path(new_user_password_path)

      fill_in "Email đăng ký", with: "test@example.com"
      click_button "Gửi link đặt lại mật khẩu"

      expect(page).to have_content("Bạn sẽ nhận được email hướng dẫn đặt lại mật khẩu trong vài phút.")
    end
  end
end
