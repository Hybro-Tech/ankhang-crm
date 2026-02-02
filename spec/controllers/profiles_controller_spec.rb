# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfilesController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user, password: "password123", password_confirmation: "password123") }

  before { sign_in user }

  describe "GET #show" do
    it "renders the profile page successfully" do
      get :show
      expect(response).to have_http_status(:ok)
    end

    it "responds with HTML content type" do
      get :show
      expect(response.content_type).to include("text/html")
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      it "updates user profile info" do
        patch :update, params: { user: { name: "New Name", phone: "0987654321" } }
        expect(response).to redirect_to(profile_path)
        expect(user.reload.name).to eq("New Name")
        expect(user.reload.phone).to eq("0987654321")
      end
    end

    context "with invalid params" do
      it "renders show with errors" do
        patch :update, params: { user: { name: "", email: "invalid" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH #update_password" do
    context "with correct current password" do
      it "changes password successfully" do
        patch :update_password, params: {
          current_password: "password123",
          password: "newpassword",
          password_confirmation: "newpassword"
        }
        expect(response).to redirect_to(profile_path)
        expect(user.reload.valid_password?("newpassword")).to be true
      end
    end

    context "with wrong current password" do
      it "shows error" do
        patch :update_password, params: {
          current_password: "wrongpassword",
          password: "newpassword",
          password_confirmation: "newpassword"
        }
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to include("không đúng")
      end
    end

    context "with password confirmation mismatch" do
      it "shows error" do
        patch :update_password, params: {
          current_password: "password123",
          password: "newpassword",
          password_confirmation: "different"
        }
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to include("không khớp")
      end
    end

    context "with password too short" do
      it "shows error" do
        patch :update_password, params: {
          current_password: "password123",
          password: "12345",
          password_confirmation: "12345"
        }
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to include("6 ký tự")
      end
    end
  end

  describe "authentication" do
    it "redirects unauthenticated users to login" do
      sign_out user
      get :show
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
