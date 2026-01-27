# frozen_string_literal: true

require "rails_helper"

RSpec.describe ServiceType, type: :model do
  describe "validations" do
    it "requires name" do
      service_type = build(:service_type, name: nil)
      expect(service_type).not_to be_valid
      expect(service_type.errors[:name]).to be_present
    end

    it "requires unique name" do
      create(:service_type, name: "Test Type")
      service_type = build(:service_type, name: "Test Type")
      expect(service_type).not_to be_valid
      expect(service_type.errors[:name]).to be_present
    end

    it "limits name to 100 characters" do
      service_type = build(:service_type, name: "a" * 101)
      expect(service_type).not_to be_valid
      expect(service_type.errors[:name]).to be_present
    end
  end

  describe "associations" do
    it "belongs to team (optional)" do
      service_type = create(:service_type, team: nil)
      expect(service_type).to be_valid
    end

    it "can have a team" do
      team = create(:team)
      service_type = create(:service_type, team: team)
      expect(service_type.team).to eq(team)
    end

    it "has many contacts" do
      expect(described_class.new).to respond_to(:contacts)
    end
  end

  describe "scopes" do
    let!(:active_type) { create(:service_type, active: true, position: 2) }
    let!(:inactive_type) { create(:service_type, active: false, position: 1) }
    let!(:first_type) { create(:service_type, active: true, position: 0) }

    describe ".active" do
      it "returns only active service types" do
        expect(described_class.active).to include(active_type, first_type)
        expect(described_class.active).not_to include(inactive_type)
      end
    end

    describe ".ordered" do
      it "orders by position asc then name asc" do
        ordered = described_class.ordered.to_a

        # Check relative ordering of our test records
        first_idx = ordered.index(first_type)
        active_idx = ordered.index(active_type)
        expect(first_idx).to be < active_idx
      end
    end

    describe ".for_dropdown" do
      it "returns active types ordered, with only id and name" do
        result = described_class.for_dropdown
        expect(result).to include(active_type, first_type)
        expect(result).not_to include(inactive_type)
      end
    end
  end
end
