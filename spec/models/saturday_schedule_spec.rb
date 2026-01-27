require 'rails_helper'

RSpec.describe SaturdaySchedule, type: :model do
  describe 'validations' do
    it 'requires a date' do
      schedule = build(:saturday_schedule, date: nil)
      expect(schedule).not_to be_valid
      expect(schedule.errors[:date]).to include("không thể để trống")
    end

    it 'requires unique date' do
      create(:saturday_schedule, date: '2026-05-30') # A saturday
      schedule = build(:saturday_schedule, date: '2026-05-30')
      expect(schedule).not_to be_valid
      expect(schedule.errors[:date]).to include("đã có trong danh sách")
    end

    it 'requires date to be a Saturday' do
      schedule = build(:saturday_schedule, date: '2026-05-31') # Sunday
      expect(schedule).not_to be_valid
      expect(schedule.errors[:date]).to include("phải là ngày Thứ Bảy")
    end

    it 'allows valid Saturday date' do
      schedule = build(:saturday_schedule, date: '2026-05-30')
      expect(schedule).to be_valid
    end
  end

  describe 'associations' do
    it 'has many users through saturday_schedule_users' do
      SaturdaySchedule.destroy_all # Clean slate
      schedule = create(:saturday_schedule)
      user = create(:user)
      schedule.users << user
      expect(schedule.users).to include(user)
    end
  end

  describe '.registered?' do
    let(:schedule) { create(:saturday_schedule) }
    let(:user) { create(:user) }

    it 'returns true if user is registered' do
      schedule.users << user
      expect(SaturdaySchedule.registered?(schedule.date, user)).to be true
    end

    it 'returns false if user is not registered' do
      expect(SaturdaySchedule.registered?(schedule.date, user)).to be false
    end
  end
end
