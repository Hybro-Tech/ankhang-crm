# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id          :bigint           not null, primary key
#  name        :string(100)      not null
#  description :text
#  region      :string(50)
#  manager_id  :bigint           FK → users.id
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_teams_on_name        (name) UNIQUE
#  index_teams_on_region      (region)
#  index_teams_on_manager_id  (manager_id)
#
# Foreign Keys
#
#  fk_rails_...  (manager_id => users.id) ON DELETE => nullify
#

# TASK-009: Team model - Phân chia nhân viên theo vùng/nhóm
class Team < ApplicationRecord
  # TASK-LOGGING: Auto-log CRUD operations
  include Loggable

  loggable category: "team"
  # Associations
  belongs_to :manager, class_name: "User", optional: true
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members

  # TASK-019: Contact relationships
  has_many :service_types, dependent: :nullify
  has_many :contacts, dependent: :nullify

  # Validations
  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :region, length: { maximum: 50 }, allow_blank: true

  # Scopes
  scope :by_region, ->(region) { where(region: region) }
  scope :with_manager, -> { where.not(manager_id: nil) }

  # Constants for region values
  REGIONS = %w[Bắc Nam Trung].freeze

  # Methods
  def member_count
    users.count
  end
end
