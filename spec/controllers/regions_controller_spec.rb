# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegionsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:super_admin) { create(:user, :super_admin) }
  let(:region) { create(:region) }

  before do
    sign_in super_admin
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      get :edit, params: { id: region.id }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_attributes) { { name: "New Region", code: "new_region", position: 1 } }

      it "creates a new Region" do
        expect do
          post :create, params: { region: valid_attributes }
        end.to change(Region, :count).by(1)
      end

      it "redirects to regions index" do
        post :create, params: { region: valid_attributes }
        expect(response).to redirect_to(regions_path)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { { name: "", code: "" } }

      it "does not create a new Region" do
        expect do
          post :create, params: { region: invalid_attributes }
        end.not_to change(Region, :count)
      end

      it "renders new template" do
        post :create, params: { region: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "Updated Name" } }

      it "updates the region" do
        patch :update, params: { id: region.id, region: new_attributes }
        region.reload
        expect(region.name).to eq("Updated Name")
      end

      it "redirects to regions index" do
        patch :update, params: { id: region.id, region: new_attributes }
        expect(response).to redirect_to(regions_path)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when region has no associations" do
      it "destroys the region" do
        region
        expect do
          delete :destroy, params: { id: region.id }
        end.to change(Region, :count).by(-1)
      end

      it "redirects to regions index" do
        delete :destroy, params: { id: region.id }
        expect(response).to redirect_to(regions_path)
      end
    end

    context "when region has users" do
      before do
        create(:user, region: region)
      end

      it "does not destroy the region" do
        expect do
          delete :destroy, params: { id: region.id }
        end.not_to change(Region, :count)
      end
    end
  end

  describe "PATCH #toggle_active" do
    it "toggles the active status" do
      region.update(active: true)
      patch :toggle_active, params: { id: region.id }
      region.reload
      expect(region.active).to be false
    end
  end
end
