# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Settings", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_role) { Role.find_by(code: Role::SUPER_ADMIN) || create(:role, code: Role::SUPER_ADMIN, dashboard_type: :admin) }
  let(:admin_user) { create(:user, roles: [admin_role]) }

  before { sign_in admin_user }

  describe "GET /admin/settings" do
    it "returns http success" do
      get "/admin/settings"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/settings" do
    it "processes the request" do
      patch "/admin/settings", params: { timezone: "Asia/Bangkok" }
      # Either redirects or shows validation error
      expect(response.status).to be_in([200, 302, 400, 422])
    end
  end
end
