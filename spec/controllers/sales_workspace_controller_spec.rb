# frozen_string_literal: true

require "rails_helper"

# TASK-064: Updated for 4 simplified statuses
RSpec.describe SalesWorkspaceController, type: :controller do
  include Devise::Test::ControllerHelpers

  let!(:team) { FactoryBot.create(:team) }
  let!(:role_sale) { Role.find_by(code: Role::SALE) || FactoryBot.create(:role, code: Role::SALE, dashboard_type: :sale) }
  let!(:user) { FactoryBot.create(:user, roles: [role_sale], teams: [team]) }

  # Contacts for testing with new 4 statuses
  let!(:contact_potential) { FactoryBot.create(:contact, assigned_user: user, status: :potential, team: team) }
  let!(:contact_closed) { FactoryBot.create(:contact, assigned_user: user, status: :closed, team: team) }

  before do
    sign_in user
    # Stub CanCanCan authorization
    allow(controller).to receive(:authorize!).and_return(true)
  end

  describe "GET #kanban" do
    it "renders the kanban view" do
      get :kanban
      expect(response).to have_http_status(:success)
    end

    it "loads kanban columns with correct data" do
      get :kanban
      columns = controller.instance_variable_get(:@kanban_columns)
      expect(columns).to be_present
      # TASK-064: Updated kanban columns to 4 statuses
      expect(columns.keys).to contain_exactly(:new_contact, :potential, :closed, :failed)

      expect(columns[:potential][:contacts]).to include(contact_potential)
      expect(columns[:closed][:contacts]).to include(contact_closed)
    end
  end

  describe "PATCH #update_status" do
    context "with valid status" do
      it "updates the contact status" do
        patch :update_status, params: { id: contact_potential.id, status: "closed" }
        expect(contact_potential.reload.status).to eq("closed")
      end

      it "redirects to kanban board on HTML request" do
        patch :update_status, params: { id: contact_potential.id, status: "closed" }
        expect(response).to redirect_to(sales_kanban_path)
        expect(flash[:notice]).to eq("Đã cập nhật trạng thái.")
      end
    end

    context "with invalid status" do
      it "does not update status" do
        patch :update_status, params: { id: contact_potential.id, status: "invalid_status" }
        expect(contact_potential.reload.status).to eq("potential")
      end
    end

    context "when contact belongs to another user" do
      let(:other_user) { FactoryBot.create(:user, roles: [role_sale]) }
      let(:other_contact) { FactoryBot.create(:contact, assigned_user: other_user) }

      it "raises ActiveRecord::RecordNotFound" do
        expect do
          patch :update_status, params: { id: other_contact.id, status: "closed" }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
