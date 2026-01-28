# frozen_string_literal: true

require "rails_helper"

RSpec.describe SalesWorkspaceController, type: :controller do
  include Devise::Test::ControllerHelpers

  let!(:role_sale) { Role.find_by(name: "Sale") || FactoryBot.create(:role, name: "Sale", dashboard_type: :sale) }
  let!(:user) { FactoryBot.create(:user, roles: [role_sale]) }

  # Contacts for testing
  let!(:contact_potential) { FactoryBot.create(:contact, assigned_user: user, status: :potential) }
  let!(:contact_in_progress) { FactoryBot.create(:contact, assigned_user: user, status: :in_progress) }

  before do
    sign_in user
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
      expect(columns.keys).to contain_exactly(:potential, :in_progress, :closed_new, :failed)

      expect(columns[:potential][:contacts]).to include(contact_potential)
      expect(columns[:in_progress][:contacts]).to include(contact_in_progress)
    end
  end

  describe "PATCH #update_status" do
    context "with valid status" do
      it "updates the contact status" do
        patch :update_status, params: { id: contact_potential.id, status: "in_progress" }
        expect(contact_potential.reload.status).to eq("in_progress")
      end

      it "redirects to kanban board on HTML request" do
        patch :update_status, params: { id: contact_potential.id, status: "in_progress" }
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
          patch :update_status, params: { id: other_contact.id, status: "in_progress" }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
