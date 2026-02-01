# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReassignRequestsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:admin) { create(:user, :super_admin) }
  let(:team) { create(:team) }
  let(:from_user) { create(:user) }
  let(:to_user) { create(:user) }
  let(:contact) { create(:contact, team: team, assigned_user: from_user) }

  before do
    sign_in admin
    team.users << from_user
  end

  describe "GET #new" do
    it "returns success for admin" do
      get :new, params: { contact_id: contact.id }
      expect(response).to be_successful
    end

    it "redirects non-admin users" do
      sign_in from_user
      get :new, params: { contact_id: contact.id }
      expect(response).to redirect_to(contacts_path)
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        contact_id: contact.id,
        reassign_request: {
          to_user_id: to_user.id,
          reason: "Test reassignment"
        }
      }
    end

    it "creates a reassign request" do
      expect do
        post :create, params: valid_params
      end.to change(ReassignRequest, :count).by(1)
    end

    it "redirects to contacts path on success" do
      post :create, params: valid_params
      expect(response).to redirect_to(contacts_path)
    end

    it "sets correct attributes" do
      post :create, params: valid_params
      request = ReassignRequest.last
      expect(request.contact).to eq(contact)
      expect(request.from_user).to eq(from_user)
      expect(request.to_user).to eq(to_user)
      expect(request.requested_by).to eq(admin)
    end
  end
end
