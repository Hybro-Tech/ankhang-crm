require 'rails_helper'

RSpec.describe 'Debug FactoryBot', type: :model do
  it 'can create a team' do
    team = FactoryBot.create(:team)
    puts "Team created: #{team.inspect}"
  end

  it 'can create a user' do
    user = FactoryBot.create(:user)
    puts "User created: #{user.inspect}"
  end
end
