# frozen_string_literal: true

require "rails_helper"

RSpec.describe DashboardController, type: :controller do
  include Devise::Test::ControllerHelpers

  # Create Roles (find or create to avoid duplicates if seeded)
  let(:role_admin) { Role.find_by(name: "Admin") || FactoryBot.create(:role, name: "Admin", dashboard_type: :admin) }
  let(:role_sale) { Role.find_by(name: "Sale") || FactoryBot.create(:role, name: "Sale", dashboard_type: :sale) }
  let(:role_call_center) do
    Role.find_by(name: "Call Center") || FactoryBot.create(:role, name: "Call Center", dashboard_type: :call_center)
  end

  # Create Users
  let(:admin_user) { FactoryBot.create(:user, roles: [role_admin], username: "admin_test") }
  let(:sale_user) { FactoryBot.create(:user, roles: [role_sale], username: "sale_test") }
  let(:call_center_user) { FactoryBot.create(:user, roles: [role_call_center], username: "cc_test") }

  describe "GET #index" do
    context "when not logged in" do
      it "redirects to login page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as Call Center" do
      before do
        # Grant permission for call center dashboard
        permission = Permission.find_or_create_by!(code: "dashboards.view_call_center") do |p|
          p.name = "View Call Center Dashboard"
          p.category = "Dashboard"
        end
        role_call_center.permissions << permission unless role_call_center.permissions.include?(permission)
        sign_in call_center_user
      end

      it "renders call_center dashboard view" do
        get :index
        expect(controller.instance_variable_get(:@dashboard_view)).to eq("call_center")
        expect(response).to have_http_status(:success)
      end

      it "loads call center stats" do
        get :index
        expect(controller.instance_variable_get(:@contacts_today)).to be_present
      end
    end

    context "when logged in as Sale" do
      before do
        sign_in sale_user
      end

      it "renders sale dashboard view" do
        get :index
        expect(controller.instance_variable_get(:@dashboard_view)).to eq("sale")
        expect(response).to have_http_status(:success)
      end

      it "loads sale KPI and charts" do
        get :index
        kpi = controller.instance_variable_get(:@kpi)
        expect(kpi).to be_present
        expect(kpi).to include(:total_contacts, :new_leads, :revenue)
        expect(controller.instance_variable_get(:@chart_data)).to be_present
        expect(controller.instance_variable_get(:@top_performers)).to be_present
      end
    end

    context "when logged in as CSKH" do
      let(:role_cskh) { Role.find_by(name: "CSKH") || FactoryBot.create(:role, name: "CSKH", dashboard_type: :cskh) }
      let(:cskh_user) { FactoryBot.create(:user, roles: [role_cskh], username: "cskh_test") }

      before { sign_in cskh_user }

      it "renders cskh dashboard view" do
        get :index
        expect(controller.instance_variable_get(:@dashboard_view)).to eq("cskh")
        expect(response).to have_http_status(:success)
      end

      it "loads cskh specific queues and stats" do
        get :index
        expect(controller.instance_variable_get(:@recovery_queue)).to be_kind_of(ActiveRecord::Relation)
        expect(controller.instance_variable_get(:@stats)).to include(:failed_today, :pending_recovery)
      end
    end

    context "when logged in as Admin" do
      before do
        # Grant permission for admin dashboard
        permission = Permission.find_or_create_by!(code: "dashboards.view_admin") do |p|
          p.name = "View Admin Dashboard"
          p.category = "Dashboard"
        end
        role_admin.permissions << permission unless role_admin.permissions.include?(permission)
        sign_in admin_user
      end

      it "renders admin dashboard view" do
        get :index
        expect(controller.instance_variable_get(:@dashboard_view)).to eq("admin")
        expect(response).to have_http_status(:success)
      end

      it "loads admin KPI stats" do
        get :index
        kpi = controller.instance_variable_get(:@kpi)
        expect(kpi).to be_present
        expect(kpi).to include(:total_contacts, :total_employees, :won_deals_count)
      end
    end
  end

  describe "GET #call_center" do
    before do
      permission = Permission.find_or_create_by(code: "dashboards.view_call_center") do |p|
        p.name = "View Call Center Dashboard"
        p.category = "Dashboard"
      end
      role_call_center.permissions << permission unless role_call_center.permissions.include?(permission)
      sign_in call_center_user
    end

    it "sets @dashboard_view and renders index" do
      get :call_center
      expect(controller.instance_variable_get(:@dashboard_view)).to eq("call_center")
      expect(response).to have_http_status(:success)
    end
  end
end
