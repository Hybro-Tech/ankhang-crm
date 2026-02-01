# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserEvent, type: :model do
  describe "associations" do
    it "belongs to user (optional)" do
      event = build(:user_event, user: nil)
      expect(event).to be_valid
    end

    it "can have a user" do
      user = create(:user)
      event = create(:user_event, user: user)
      expect(event.user).to eq(user)
    end
  end

  describe "scopes" do
    describe ".recent" do
      it "orders by created_at desc" do
        old_event = create(:user_event, created_at: 1.week.ago)
        new_event = create(:user_event, created_at: 1.hour.ago)
        results = UserEvent.where(id: [old_event.id, new_event.id]).recent
        expect(results.first).to eq(new_event)
      end
    end

    describe ".by_event_type" do
      it "filters by event type" do
        page_view = create(:user_event, event_type: "page_view")
        ajax_call = create(:user_event, event_type: "ajax")
        expect(UserEvent.by_event_type("page_view")).to include(page_view)
        expect(UserEvent.by_event_type("page_view")).not_to include(ajax_call)
      end
    end

    describe ".successful" do
      it "returns 2xx status events" do
        success_event = create(:user_event, response_status: 200)
        error_event = create(:user_event, response_status: 500)
        expect(UserEvent.successful).to include(success_event)
        expect(UserEvent.successful).not_to include(error_event)
      end
    end

    describe ".errors" do
      it "returns 4xx-5xx status events" do
        success_event = create(:user_event, response_status: 200)
        error_event = create(:user_event, response_status: 500)
        expect(UserEvent.errors).to include(error_event)
        expect(UserEvent.errors).not_to include(success_event)
      end
    end

    describe ".in_date_range" do
      it "filters by date range" do
        old_event = create(:user_event, created_at: 1.week.ago)
        new_event = create(:user_event, created_at: 1.hour.ago)
        events = UserEvent.in_date_range(2.days.ago, Time.current)
        expect(events).to include(new_event)
        expect(events).not_to include(old_event)
      end
    end
  end

  describe "factory" do
    it "creates valid user event" do
      event = build(:user_event)
      expect(event).to be_valid
    end
  end
end
