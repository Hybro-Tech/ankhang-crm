# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboards", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_role) { Role.find_by(code: Role::SUPER_ADMIN) || create(:role, code: Role::SUPER_ADMIN, dashboard_type: :admin) }
  let(:admin_user) { create(:user, roles: [admin_role]) }

  before { sign_in admin_user }

  describe "GET /dashboard/index" do
    it "returns http success" do
      get "/dashboard/index"
      expect(response).to have_http_status(:success)
    end
  end
end
