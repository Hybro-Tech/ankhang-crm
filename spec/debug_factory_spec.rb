# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Debug FactoryBot", type: :model do
  it "can create a team" do
    team = FactoryBot.create(:team)
    Rails.logger.debug { "Team created: #{team.inspect}" }
  end

  it "can create a user" do
    user = FactoryBot.create(:user)
    Rails.logger.debug { "User created: #{user.inspect}" }
  end
end
