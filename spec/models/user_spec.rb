# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it "has many team_members" do
      association = User.reflect_on_association(:team_members)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it "has many teams through team_members" do
      association = User.reflect_on_association(:teams)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:team_members)
    end

    it "has one managed_team" do
      association = User.reflect_on_association(:managed_team)
      expect(association.macro).to eq(:has_one)
      expect(association.options[:class_name]).to eq("Team")
      expect(association.options[:foreign_key]).to eq(:manager_id)
      expect(association.options[:dependent]).to eq(:nullify)
    end
  end
end
