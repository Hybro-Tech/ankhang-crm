# frozen_string_literal: true

require "rails_helper"

RSpec.describe Teams::ReassignRequestsController, type: :controller do
  let(:team) { create(:team) }
  let(:leader) { create(:user) }
  let(:from_user) { create(:user) }
  let(:to_user) { create(:user) }
  let(:contact) { create(:contact, team: team, assigned_user: from_user) }
  let(:admin) { create(:user, :super_admin) }

  let!(:reassign_request) do
    create(:reassign_request,
           contact: contact,
           from_user: from_user,
           to_user: to_user,
           requested_by: admin)
  end

  before do
    team.update!(manager: leader)
    team.users << from_user
    team.users << to_user
    sign_in leader
  end

  describe "GET #index" do
    it "returns success" do
      get :index

      expect(response).to be_successful
    end

    it "loads pending requests for approver" do
      get :index

      expect(assigns(:reassign_requests)).to include(reassign_request)
    end
  end

  describe "POST #approve" do
    it "approves the request" do
      post :approve, params: { id: reassign_request.id }

      reassign_request.reload
      expect(reassign_request.status).to eq("approved")
      expect(reassign_request.approved_by).to eq(leader)
    end

    it "executes the reassignment" do
      post :approve, params: { id: reassign_request.id }

      contact.reload
      expect(contact.assigned_user).to eq(to_user)
    end

    it "redirects with success message" do
      post :approve, params: { id: reassign_request.id }

      expect(response).to redirect_to(teams_reassign_requests_path)
      expect(flash[:notice]).to be_present
    end
  end

  describe "POST #reject" do
    let(:rejection_reason) { "Không đủ điều kiện để chuyển" }

    it "rejects the request" do
      post :reject, params: { id: reassign_request.id, rejection_reason: rejection_reason }

      reassign_request.reload
      expect(reassign_request.status).to eq("rejected")
      expect(reassign_request.rejection_reason).to eq(rejection_reason)
    end

    it "does not change the contact assignment" do
      original_user = contact.assigned_user

      post :reject, params: { id: reassign_request.id, rejection_reason: rejection_reason }

      contact.reload
      expect(contact.assigned_user).to eq(original_user)
    end
  end

  describe "authorization" do
    context "when user is not a team leader" do
      let(:regular_user) { create(:user) }

      before do
        sign_out leader
        sign_in regular_user
      end

      it "denies access to index" do
        get :index

        expect(response).to redirect_to(root_path)
      end

      it "denies access to approve" do
        post :approve, params: { id: reassign_request.id }

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "unassign workflow" do
    let!(:unassign_request) do
      create(:reassign_request, :unassign,
             contact: contact,
             from_user: from_user,
             requested_by: admin)
    end

    it "returns contact to pool on approve" do
      post :approve, params: { id: unassign_request.id }

      contact.reload
      expect(contact.assigned_user).to be_nil
    end
  end
end
