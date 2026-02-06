# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Settings", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:sale_role) { Role.find_by(code: "sale") || create(:role, code: "sale", dashboard_type: :sales) }
  let(:call_center_role) { Role.find_by(code: "call_center") || create(:role, code: "call_center", dashboard_type: :call_center) }
  let(:sale_user) { create(:user, roles: [sale_role]) }
  let(:call_center_user) { create(:user, roles: [call_center_role]) }

  describe "GET /settings" do
    context "when user is sale" do
      before { sign_in sale_user }

      it "returns http success" do
        get "/settings"
        expect(response).to have_http_status(:success)
      end

      it "displays the settings page" do
        get "/settings"
        expect(response.body).to include("Cài đặt")
        expect(response.body).to include("Thông báo đẩy")
      end
    end

    context "when user is call center" do
      before { sign_in call_center_user }

      it "returns http success" do
        get "/settings"
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not authenticated" do
      it "redirects to login" do
        get "/settings"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
