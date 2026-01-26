require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'associations' do
    it 'belongs to manager' do
      association = Team.reflect_on_association(:manager)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq('User')
      expect(association.options[:optional]).to eq(true)
    end

    it 'has many team_members' do
      association = Team.reflect_on_association(:team_members)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has many users through team_members' do
      association = Team.reflect_on_association(:users)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:team_members)
    end
  end

  describe 'validations' do
    it 'validates presence of name' do
      team = Team.new(name: nil)
      expect(team).not_to be_valid
      expect(team.errors[:name]).not_to be_empty
    end

    it 'validates uniqueness of name' do
      Team.create(name: 'Existing Team')
      team = Team.new(name: 'Existing Team')
      expect(team).not_to be_valid
      expect(team.errors[:name]).not_to be_empty
    end

    it 'validates length of name' do
      team = Team.new(name: 'a' * 101)
      expect(team).not_to be_valid
      expect(team.errors[:name]).not_to be_empty
    end
  end

  describe '#member_count' do
    let(:team) { Team.create(name: 'Sales Team') }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    before do
      TeamMember.create(team: team, user: user1)
      TeamMember.create(team: team, user: user2)
    end

    it 'returns correct count of members' do
      expect(team.member_count).to eq(2)
    end
  end
end
