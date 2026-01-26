# frozen_string_literal: true

require "rails_helper"

RSpec.describe Holiday, type: :model do
  describe "validations" do
    it "requires name" do
      holiday = Holiday.new(date: Time.zone.today)
      expect(holiday).not_to be_valid
      expect(holiday.errors[:name]).to be_present
    end

    it "requires date" do
      holiday = Holiday.new(name: "Test")
      expect(holiday).not_to be_valid
      expect(holiday.errors[:date]).to be_present
    end

    it "requires unique date" do
      create(:holiday, date: "2099-05-01", name: "Labor Day Future")
      duplicate = build(:holiday, date: "2099-05-01", name: "Another")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:date]).to be_present
    end
  end

  describe ".holiday?" do
    let!(:holiday) { create(:holiday, date: "2099-01-01", name: "Future New Year") }

    it "returns true for a holiday date" do
      expect(Holiday.holiday?("2099-01-01")).to be true
      expect(Holiday.holiday?(Date.parse("2099-01-01"))).to be true
    end

    it "returns false for a non-holiday date" do
      expect(Holiday.holiday?("2025-01-02")).to be false
    end

    it "returns false for nil" do
      expect(Holiday.holiday?(nil)).to be false
    end
  end

  describe "scopes" do
    let!(:past_holiday) { create(:holiday, date: 1.day.ago, name: "Past") }
    let!(:future_holiday) { create(:holiday, date: 1.day.from_now, name: "Future") }

    it "returns upcoming holidays" do
      expect(Holiday.upcoming).to include(future_holiday)
      expect(Holiday.upcoming).not_to include(past_holiday)
    end

    it "returns past holidays" do
      expect(Holiday.past).to include(past_holiday)
      expect(Holiday.past).not_to include(future_holiday)
    end
  end
end
