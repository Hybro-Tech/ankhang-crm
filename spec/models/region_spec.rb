# frozen_string_literal: true

require "rails_helper"

RSpec.describe Region, type: :model do
  describe "associations" do
    it "has many users" do
      association = described_class.reflect_on_association(:users)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      region = build(:region)
      expect(region).to be_valid
    end

    it "is invalid without a name" do
      region = build(:region, name: nil)
      expect(region).not_to be_valid
    end

    it "is invalid without a code" do
      region = build(:region, code: nil)
      expect(region).not_to be_valid
    end

    it "is invalid with duplicate name" do
      create(:region, name: "Unique Name")
      region = build(:region, name: "Unique Name")
      expect(region).not_to be_valid
    end

    it "is invalid with invalid code format" do
      region = build(:region, code: "Invalid-Code")
      expect(region).not_to be_valid
      expect(region.errors[:code]).to include("chỉ cho phép chữ thường, số và dấu gạch dưới")
    end

    it "is valid with valid code format" do
      region = build(:region, code: "valid_code")
      expect(region).to be_valid
    end
  end

  describe "scopes" do
    before { described_class.destroy_all }

    let!(:active_region) { create(:region, active: true, position: 2) }
    let!(:inactive_region) { create(:region, active: false, position: 1) }

    describe ".active" do
      it "returns only active regions" do
        expect(described_class.active).to include(active_region)
        expect(described_class.active).not_to include(inactive_region)
      end
    end

    describe ".ordered" do
      it "orders by position and name" do
        expect(described_class.ordered.first).to eq(inactive_region)
      end
    end

    describe ".for_select" do
      it "returns active regions as [name, id] pairs" do
        result = described_class.for_select
        expect(result).to include([active_region.name, active_region.id])
        expect(result).not_to include([inactive_region.name, inactive_region.id])
      end
    end
  end

  describe ".seed_defaults!" do
    before { described_class.destroy_all }

    it "creates default regions" do
      expect { described_class.seed_defaults! }.to change(described_class, :count).by(3)
      expect(described_class.pluck(:code)).to include("bac", "trung", "nam")
    end

    it "is idempotent" do
      described_class.seed_defaults!
      expect { described_class.seed_defaults! }.not_to change(described_class, :count)
    end
  end
end
