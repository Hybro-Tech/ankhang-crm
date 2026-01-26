# frozen_string_literal: true

# Join table for Users and Teams
class TeamMember < ApplicationRecord
  belongs_to :user
  belongs_to :team

  validates :user_id, uniqueness: { scope: :team_id, message: "đã thuộc team này rồi" }
end
