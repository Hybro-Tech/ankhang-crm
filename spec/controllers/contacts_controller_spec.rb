# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContactsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:admin_role) { Role.find_by(code: Role::SUPER_ADMIN) || create(:role, code: Role::SUPER_ADMIN, dashboard_type: :admin) }
  let(:sale_role) { Role.find_by(code: Role::SALE) || create(:role, code: Role::SALE, dashboard_type: :sale) }
  let(:tongdai_role) { Role.find_by(code: Role::CALL_CENTER) || create(:role, code: Role::CALL_CENTER, dashboard_type: :call_center) }

  let(:admin_user) { create(:user, roles: [admin_role]) }
  let(:sale_user) { create(:user, roles: [sale_role]) }
  let(:tongdai_user) { create(:user, roles: [tongdai_role]) }

  let(:contacts_create_perm) do
    Permission.find_or_create_by!(code: "contacts.create") do |p|
      p.name = "Create Contacts"
      p.category = "Contacts"
    end
  end

  let(:contacts_view_perm) do
    Permission.find_or_create_by!(code: "contacts.view") do |p|
      p.name = "View Contacts"
      p.category = "Contacts"
    end
  end

  describe "GET #check_phone" do
    context "when user has contacts.create permission" do
      before do
        tongdai_role.permissions << contacts_create_perm unless tongdai_role.permissions.include?(contacts_create_perm)
        sign_in tongdai_user
      end

      it "returns JSON response" do
        get :check_phone, params: { phone: "0901234567" }, format: :json
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include("application/json")
      end

      it "returns exists: false for new phone" do
        get :check_phone, params: { phone: "0909999999" }, format: :json
        json = response.parsed_body
        expect(json["exists"]).to be false
      end

      it "returns exists: true for existing phone" do
        contact = create(:contact, phone: "0901234567")
        get :check_phone, params: { phone: "0901234567" }, format: :json
        json = response.parsed_body
        expect(json["exists"]).to be true
        expect(json["contact_name"]).to eq(contact.name)
      end
    end

    context "when user lacks contacts.create permission" do
      let(:no_perm_role) { create(:role, name: "NoPerms", code: "no_perms") }
      let(:no_perm_user) { create(:user, roles: [no_perm_role]) }

      before { sign_in no_perm_user }

      it "denies access" do
        get :check_phone, params: { phone: "0901234567" }, format: :json
        expect(response).to have_http_status(:forbidden).or redirect_to(root_path)
      end
    end

    context "when super admin" do
      before { sign_in admin_user }

      it "allows access" do
        get :check_phone, params: { phone: "0901234567" }, format: :json
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #check_identity" do
    context "when user has contacts.create permission" do
      before do
        tongdai_role.permissions << contacts_create_perm unless tongdai_role.permissions.include?(contacts_create_perm)
        sign_in tongdai_user
      end

      it "returns JSON for phone lookup" do
        get :check_identity, params: { phone: "0901234567" }, format: :json
        expect(response).to have_http_status(:success)
      end

      it "returns JSON for zalo_id lookup" do
        get :check_identity, params: { zalo_id: "zalo123" }, format: :json
        expect(response).to have_http_status(:success)
      end
    end

    context "when user lacks permission" do
      let(:no_perm_role) { create(:role, name: "NoPerms2", code: "no_perms2") }
      let(:no_perm_user) { create(:user, roles: [no_perm_role]) }

      before { sign_in no_perm_user }

      it "denies access" do
        get :check_identity, params: { phone: "0901234567" }, format: :json
        expect(response).to have_http_status(:forbidden).or redirect_to(root_path)
      end
    end
  end

  describe "GET #recent" do
    context "when user has contacts.view permission" do
      before do
        tongdai_role.permissions << contacts_view_perm unless tongdai_role.permissions.include?(contacts_view_perm)
        sign_in tongdai_user
      end

      it "returns recent contacts" do
        get :recent, format: :turbo_stream
        expect(response).to have_http_status(:success)
      end
    end

    context "when user lacks permission" do
      let(:no_perm_role) { create(:role, name: "NoPerms3", code: "no_perms3") }
      let(:no_perm_user) { create(:user, roles: [no_perm_role]) }

      before { sign_in no_perm_user }

      it "denies access with flash message" do
        get :recent, format: :turbo_stream
        # CanCanCan handles access denied with turbo stream flash
        expect(response.body).to include("turbo-stream")
      end
    end
  end
end
