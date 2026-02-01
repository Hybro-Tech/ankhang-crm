# frozen_string_literal: true

# == Schema Information
#
# Table name: service_types
#
#  id                     :bigint           not null, primary key
#  name                   :string(100)      not null
#  description            :text
#  team_id                :bigint           FK → teams.id (Default team for routing)
#  active                 :boolean          default(true), not null
#  position               :integer          default(0), not null
#  max_pick_per_day       :integer          default(20), not null  # TASK-022b
#  pick_cooldown_minutes  :integer          default(5), not null   # TASK-022b
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_service_types_on_name     (name) UNIQUE
#  index_service_types_on_active   (active)
#  index_service_types_on_team_id  (team_id)
#
# Foreign Keys
#
#  fk_rails_... (team_id => teams.id) ON DELETE => nullify
#

# TASK-019: ServiceType model - Loại nhu cầu của khách hàng
# Used by Contact for service categorization and Smart Routing
# TASK-022b: Added pick rules (max_pick_per_day, pick_cooldown_minutes)
class ServiceType < ApplicationRecord
  include Loggable

  # Associations
  belongs_to :team, optional: true
  has_many :contacts, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :max_pick_per_day, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :pick_cooldown_minutes, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 60 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc, name: :asc) }
  scope :for_dropdown, -> { active.ordered.select(:id, :name) }

  # Methods
  def display_name
    name
  end
end
