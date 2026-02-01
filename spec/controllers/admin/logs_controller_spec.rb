# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::LogsController, type: :request do
  let(:super_admin_role) { Role.find_by(code: Role::SUPER_ADMIN) || create(:role, code: Role::SUPER_ADMIN, dashboard_type: :admin) }
  let(:sale_role) { Role.find_by(code: Role::SALE) || create(:role, code: Role::SALE, dashboard_type: :sale) }

  let(:super_admin) { create(:user, roles: [super_admin_role]) }
  let(:sale_user) { create(:user, roles: [sale_role]) }

  describe "GET /admin/logs" do
    context "when super_admin" do
      before { sign_in super_admin }

      it "renders index page" do
        get admin_logs_path
        expect(response).to have_http_status(:success)
      end

      it "displays activity logs" do
        create(:activity_log, user: super_admin)
        get admin_logs_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Nhật ký hoạt động")
      end

      it "filters by category" do
        create(:activity_log, category: "contacts")
        get admin_logs_path, params: { category: "contacts" }
        expect(response).to have_http_status(:success)
      end

      it "filters by date range" do
        get admin_logs_path, params: { date_from: 5.days.ago.to_date, date_to: Date.current }
        expect(response).to have_http_status(:success)
      end
    end

    context "when sale user (no permission)" do
      before { sign_in sale_user }

      it "denies access" do
        get admin_logs_path
        expect(response.status).to be_in([302, 403])
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        get admin_logs_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/logs/events" do
    context "when super_admin" do
      before { sign_in super_admin }

      it "renders events page" do
        get events_admin_logs_path
        expect(response).to have_http_status(:success)
      end

      it "displays user events" do
        create(:user_event, user: super_admin)
        get events_admin_logs_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("User Events")
      end

      it "filters by event_type" do
        create(:user_event, event_type: "page_view")
        get events_admin_logs_path, params: { event_type: "page_view" }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/logs/archives" do
    context "when super_admin" do
      before { sign_in super_admin }

      it "renders archives page" do
        get archives_admin_logs_path
        expect(response).to have_http_status(:success)
      end

      it "displays archive counts" do
        get archives_admin_logs_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Log Archives")
      end
    end
  end
end
