# frozen_string_literal: true

# == Schema Information
#
# Table name: provinces
#
#  id         :bigint           not null, primary key
#  name       :string(100)      not null
#  code       :string(20)       not null
#  position   :integer          default(0)
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_provinces_on_name     (name) UNIQUE
#  index_provinces_on_code     (code) UNIQUE
#  index_provinces_on_active   (active)
#  index_provinces_on_position (position)
#

# TASK-061: Province model for 63 Vietnamese provinces
class Province < ApplicationRecord
  include Loggable

  loggable category: "province"

  # Associations
  has_many :province_regions, dependent: :destroy
  has_many :regions, through: :province_regions
  has_many :contacts, dependent: :nullify

  # Validations
  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :code, presence: true, uniqueness: true, length: { maximum: 20 },
                   format: { with: /\A[A-Z0-9_]+\z/, message: "chỉ cho phép chữ in hoa, số và dấu gạch dưới" }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :name) }
  scope :for_select, -> { active.ordered.pluck(:name, :id) }

  # Get region names for display
  def region_names
    regions.pluck(:name).join(", ")
  end
end
