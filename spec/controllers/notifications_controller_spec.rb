# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:admin_role) { Role.find_by(code: Role::SUPER_ADMIN) || create(:role, code: Role::SUPER_ADMIN, dashboard_type: :admin) }
  let(:sale_role) { Role.find_by(code: Role::SALE) || create(:role, code: Role::SALE, dashboard_type: :sale) }

  let(:admin_user) { create(:user, roles: [admin_role]) }
  let(:sale_user) { create(:user, roles: [sale_role]) }

  let(:notifications_view_perm) do
    Permission.find_or_create_by!(code: "notifications.view") do |p|
      p.name = "View Notifications"
      p.category = "Notifications"
    end
  end

  describe "GET #index" do
    context "when user has notifications.view permission" do
      before do
        sale_role.permissions << notifications_view_perm unless sale_role.permissions.include?(notifications_view_perm)
        sign_in sale_user
      end

      it "renders index page" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "loads user notifications page" do
        create(:notification, user: sale_user)
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context "when super admin" do
      before { sign_in admin_user }

      it "allows access" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context "when user lacks permission" do
      let(:no_perm_role) { create(:role, name: "NoNotifPerms", code: "no_notif_perms") }
      let(:no_perm_user) { create(:user, roles: [no_perm_role]) }

      before { sign_in no_perm_user }

      it "denies access" do
        get :index
        # Expect either forbidden or redirect
        expect(response.status).to be_in([403, 302])
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET #unread_count" do
    before { sign_in sale_user }

    it "returns JSON with count" do
      get :unread_count, format: :json
      expect(response).to have_http_status(:success)
      json = response.parsed_body
      expect(json).to have_key("count")
    end
  end

  describe "POST #mark_as_read" do
    before { sign_in sale_user }

    let(:notification) { create(:notification, user: sale_user) }

    it "marks notification as read" do
      post :mark_as_read, params: { id: notification.id }, format: :json
      expect(response).to have_http_status(:success)
      expect(notification.reload.read).to be true
    end
  end

  describe "POST #mark_all_as_read" do
    before { sign_in sale_user }

    it "marks all notifications as read" do
      create_list(:notification, 3, user: sale_user)
      post :mark_all_as_read, format: :json
      expect(response).to have_http_status(:success)
      expect(sale_user.notifications.unread.count).to eq(0)
    end
  end
end
