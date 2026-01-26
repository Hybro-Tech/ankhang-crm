# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication", type: :system do
  let!(:user) do
    create(:user, email: "auth_test_#{SecureRandom.hex(4)}@example.com", password: "password123",
                  username: "testuser_#{SecureRandom.hex(4)}")
  end

  describe "Login" do
    it "allows user to sign in with email" do
      visit new_user_session_path

      find("#user_login").set(user.email)
      find("#user_password").set("password123")
      click_button "Đăng nhập"

      expect(page).to have_content("Đăng nhập thành công.")
    end

    it "allows user to sign in with username" do
      visit new_user_session_path

      find("#user_login").set(user.username)
      find("#user_password").set("password123")
      click_button "Đăng nhập"

      expect(page).to have_content("Đăng nhập thành công.")
    end

    it "rejects invalid credentials" do
      visit new_user_session_path

      find("#user_login").set(user.email)
      find("#user_password").set("wrongpassword")
      click_button "Đăng nhập"

      expect(page).to have_content("Email hoặc mật khẩu không đúng.")
    end
  end

  describe "Forgot Password" do
    it "sends reset password instructions" do
      visit new_user_password_path

      find("#user_email").set(user.email)
      click_button "Gửi link đặt lại mật khẩu"

      expect(page).to have_content("Bạn sẽ nhận được email hướng dẫn đặt lại mật khẩu trong vài phút.")
    end
  end
end
