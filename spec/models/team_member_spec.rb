# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeamMember, type: :model do
  describe "associations" do
    it "belongs to user" do
      association = TeamMember.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to team" do
      association = TeamMember.reflect_on_association(:team)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    let(:user) { create(:user) }
    let(:team) { Team.create(name: "Test Team") }

    before { TeamMember.create(user: user, team: team) }

    it "validates uniqueness of user within team" do
      duplicate_membership = TeamMember.new(user: user, team: team)
      expect(duplicate_membership).not_to be_valid
      expect(duplicate_membership.errors[:user_id]).to include("đã thuộc team này rồi")
    end
  end
end
