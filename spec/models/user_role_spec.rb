# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserRole, type: :model do
  describe "associations" do
    it "belongs to user" do
      expect(described_class.reflect_on_association(:user).macro).to eq(:belongs_to)
    end

    it "belongs to role" do
      expect(described_class.reflect_on_association(:role).macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    let(:user) { create(:user) }
    let(:role) { create(:role) }

    it "allows creating a user_role" do
      ur = described_class.new(user: user, role: role)
      expect(ur).to be_valid
    end

    it "does not allow duplicate user-role combination" do
      described_class.create!(user: user, role: role)
      duplicate = described_class.new(user: user, role: role)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("đã có vai trò này")
    end

    it "allows same role for different users" do
      other_user = create(:user)
      described_class.create!(user: user, role: role)

      other_ur = described_class.new(user: other_user, role: role)
      expect(other_ur).to be_valid
    end

    it "allows same user for different roles" do
      other_role = create(:role)
      described_class.create!(user: user, role: role)

      other_ur = described_class.new(user: user, role: other_role)
      expect(other_ur).to be_valid
    end
  end
end
