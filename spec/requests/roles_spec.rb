# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Roles", type: :request do
  let(:admin_user) { create(:user, :super_admin) }

  before do
    sign_in(admin_user)
  end

  describe "GET /roles" do
    it "returns success" do
      get roles_path
      expect(response).to have_http_status(:success)
    end

    it "lists all roles" do
      get roles_path
      expect(response.body).to include("Danh sách vai trò")
    end
  end

  describe "GET /roles/new" do
    it "returns success" do
      get new_role_path
      expect(response).to have_http_status(:success)
    end

    it "shows permission matrix" do
      Permission.find_or_create_by!(code: "contacts.view") do |p|
        p.name = "Xem Contact"
        p.category = "Contacts"
      end
      get new_role_path
      expect(response.body).to include("Phân quyền")
    end
  end

  describe "POST /roles" do
    let(:valid_params) do
      { role: { name: "New Test Role", description: "Test description" } }
    end

    it "creates a new role" do
      expect do
        post roles_path, params: valid_params
      end.to change(Role, :count).by(1)
    end

    it "redirects to index with success message" do
      post roles_path, params: valid_params
      expect(response).to redirect_to(roles_path)
      follow_redirect!
      expect(response.body).to include("Vai trò đã được tạo thành công")
    end
  end

  describe "GET /roles/:id/edit" do
    let!(:role) { create(:role, name: "Editable Role") }

    it "returns success" do
      get edit_role_path(role)
      expect(response).to have_http_status(:success)
    end

    it "shows role info" do
      get edit_role_path(role)
      expect(response.body).to include("Editable Role")
    end
  end

  describe "PATCH /roles/:id" do
    let!(:role) { create(:role, name: "Original Name") }

    it "updates the role" do
      patch role_path(role), params: { role: { name: "Updated Name" } }
      expect(role.reload.name).to eq("Updated Name")
    end

    it "redirects to index with success message" do
      patch role_path(role), params: { role: { name: "Updated Name" } }
      expect(response).to redirect_to(roles_path)
    end
  end

  describe "DELETE /roles/:id" do
    context "with non-system role" do
      let!(:role) { create(:role, name: "Deletable Role", is_system: false) }

      it "deletes the role" do
        expect do
          delete role_path(role)
        end.to change(Role, :count).by(-1)
      end

      it "redirects to index with success message" do
        delete role_path(role)
        expect(response).to redirect_to(roles_path)
      end
    end

    context "with system role" do
      let!(:system_role) { Role.find_or_create_by!(name: "Test System", is_system: true) }

      it "does not delete the role" do
        expect do
          delete role_path(system_role)
        end.not_to change(Role, :count)
      end

      it "shows error message" do
        delete role_path(system_role)
        expect(response).to redirect_to(roles_path)
        follow_redirect!
        expect(response.body).to include("Không thể xóa system role")
      end
    end
  end

  describe "POST /roles/:id/clone" do
    let!(:role) { create(:role, name: "Original Role") }
    let(:contacts_perm) do
      Permission.find_or_create_by!(code: "contacts.view") do |p|
        p.name = "Xem Contact"
        p.category = "Contacts"
      end
    end

    before do
      role.permissions << contacts_perm unless role.permissions.include?(contacts_perm)
    end

    it "creates a new role with same permissions" do
      expect do
        post clone_role_path(role)
      end.to change(Role, :count).by(1)
    end

    it "names the cloned role with (Copy) suffix" do
      post clone_role_path(role)
      cloned_role = Role.find_by(name: "Original Role (Copy)")
      expect(cloned_role).to be_present
    end

    it "clones the permissions" do
      post clone_role_path(role)
      cloned_role = Role.find_by(name: "Original Role (Copy)")
      expect(cloned_role.permissions).to include(contacts_perm)
    end
  end
end
