# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ReassignRequestsController, type: :controller do
  let(:admin) { create(:user, :super_admin) }
  let(:team) { create(:team) }
  let(:contact) { create(:contact, team: team, assigned_user: from_user) }
  let(:from_user) { create(:user) }
  let(:to_user) { create(:user) }

  before do
    sign_in admin
    team.users << from_user
    team.users << to_user
    team.update!(manager: create(:user))
  end

  describe "GET #new" do
    it "returns success" do
      get :new, params: { contact_id: contact.id }

      expect(response).to be_successful
    end

    it "assigns the contact" do
      get :new, params: { contact_id: contact.id }

      expect(assigns(:contact)).to eq(contact)
    end

    it "assigns available users" do
      get :new, params: { contact_id: contact.id }

      expect(assigns(:available_users)).to be_present
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        contact_id: contact.id,
        reassign_request: {
          request_type: "reassign",
          to_user_id: to_user.id,
          reason: "Khách hàng yêu cầu đổi nhân viên"
        }
      }
    end

    context "with valid params" do
      it "creates a new ReassignRequest" do
        expect do
          post :create, params: valid_params
        end.to change(ReassignRequest, :count).by(1)
      end

      it "sets correct attributes" do
        post :create, params: valid_params

        request = ReassignRequest.last
        expect(request.contact).to eq(contact)
        expect(request.from_user).to eq(from_user)
        expect(request.to_user).to eq(to_user)
        expect(request.requested_by).to eq(admin)
        expect(request.status).to eq("pending")
      end

      it "redirects to contacts index" do
        post :create, params: valid_params

        expect(response).to redirect_to(admin_contacts_path)
      end
    end

    context "with unassign type" do
      let(:unassign_params) do
        {
          contact_id: contact.id,
          reassign_request: {
            request_type: "unassign",
            reason: "Nhân viên nghỉ việc"
          }
        }
      end

      it "creates unassign request without to_user" do
        post :create, params: unassign_params

        request = ReassignRequest.last
        expect(request.unassign?).to be true
        expect(request.to_user).to be_nil
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          contact_id: contact.id,
          reassign_request: {
            request_type: "reassign",
            to_user_id: nil,
            reason: ""
          }
        }
      end

      it "does not create a request" do
        expect do
          post :create, params: invalid_params
        end.not_to change(ReassignRequest, :count)
      end

      it "renders unprocessable_entity" do
        post :create, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "authorization" do
    let(:regular_user) { create(:user) }

    before do
      sign_out admin
      sign_in regular_user
    end

    it "denies access to non-admin users" do
      get :new, params: { contact_id: contact.id }

      expect(response).to redirect_to(root_path)
    end
  end
end
