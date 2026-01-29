# frozen_string_literal: true

require "rails_helper"

RSpec.describe RolePermission, type: :model do
  describe "associations" do
    it "belongs to role" do
      expect(described_class.reflect_on_association(:role).macro).to eq(:belongs_to)
    end

    it "belongs to permission" do
      expect(described_class.reflect_on_association(:permission).macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    let(:role) { create(:role) }
    let(:permission) { create(:permission) }

    it "allows creating a role_permission" do
      rp = described_class.new(role: role, permission: permission)
      expect(rp).to be_valid
    end

    it "does not allow duplicate role-permission combination" do
      described_class.create!(role: role, permission: permission)
      duplicate = described_class.new(role: role, permission: permission)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:role_id]).to include("đã có quyền này")
    end

    it "allows same permission for different roles" do
      other_role = create(:role)
      described_class.create!(role: role, permission: permission)

      other_rp = described_class.new(role: other_role, permission: permission)
      expect(other_rp).to be_valid
    end

    it "allows same role for different permissions" do
      other_permission = create(:permission)
      described_class.create!(role: role, permission: permission)

      other_rp = described_class.new(role: role, permission: other_permission)
      expect(other_rp).to be_valid
    end
  end
end
