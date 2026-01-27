require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  include Devise::Test::ControllerHelpers

  # Create Roles (find or create to avoid duplicates if seeded)
  let(:role_admin) { Role.find_by(name: 'Admin') || FactoryBot.create(:role, name: 'Admin') }
  let(:role_sale) { Role.find_by(name: 'Sale') || FactoryBot.create(:role, name: 'Sale') }
  let(:role_call_center) { Role.find_by(name: 'Call Center') || FactoryBot.create(:role, name: 'Call Center') }

  # Create Users
  let(:admin_user) { FactoryBot.create(:user, roles: [role_admin], username: 'admin_test') }
  let(:sale_user) { FactoryBot.create(:user, roles: [role_sale], username: 'sale_test') }
  let(:call_center_user) { FactoryBot.create(:user, roles: [role_call_center], username: 'cc_test') }

  describe "GET #index" do
    context "when not logged in" do
      it "redirects to login page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as Call Center" do
      before do 
        sign_in call_center_user
        # Mock permission if needed, but assuming index is open to auth users
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

    context "when logged in as Admin" do
      before do
        sign_in admin_user
      end

      it "renders admin dashboard view" do
        get :index
        expect(controller.instance_variable_get(:@dashboard_view)).to eq("admin")
        expect(response).to have_http_status(:success)
      end

      it "loads generic stats" do
        get :index
        expect(controller.instance_variable_get(:@total_contacts)).to be_present
      end
    end
  end
end
