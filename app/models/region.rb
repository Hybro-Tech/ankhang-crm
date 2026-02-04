# frozen_string_literal: true

# == Schema Information
#
# Table name: regions
#
#  id          :bigint           not null, primary key
#  name        :string(100)      not null
#  code        :string(20)       not null
#  description :text
#  position    :integer          default(0)
#  active      :boolean          default(TRUE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_regions_on_code      (code) UNIQUE
#  index_regions_on_name      (name) UNIQUE
#  index_regions_on_position  (position)
#  index_regions_on_active    (active)
#

# TASK-REGION: Dynamic Region management for Admin
class Region < ApplicationRecord
  # TASK-LOGGING: Auto-log CRUD operations
  include Loggable

  loggable category: "region"

  # Associations
  has_many :users, dependent: :nullify
  has_many :teams, foreign_key: :region, primary_key: :name, dependent: :nullify, inverse_of: false

  # TASK-061: Province associations (many-to-many)
  has_many :province_regions, dependent: :destroy
  has_many :provinces, through: :province_regions

  # Validations
  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :code, presence: true, uniqueness: true, length: { maximum: 20 },
                   format: { with: /\A[a-z0-9_]+\z/, message: "chỉ cho phép chữ thường, số và dấu gạch dưới" }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :name) }
  scope :for_select, -> { active.ordered.pluck(:name, :id) }

  # Default regions for seeding
  DEFAULTS = [
    { name: "Bắc", code: "bac", position: 1 },
    { name: "Trung", code: "trung", position: 2 },
    { name: "Nam", code: "nam", position: 3 }
  ].freeze

  # Class method to seed default regions
  def self.seed_defaults!
    DEFAULTS.each do |attrs|
      find_or_create_by!(code: attrs[:code]) do |region|
        region.name = attrs[:name]
        region.position = attrs[:position]
        region.active = true
      end
    end
  end
end
