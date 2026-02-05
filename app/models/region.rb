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

  # Callbacks - Auto-generate code from name
  before_validation :generate_code_from_name, if: -> { name.present? && (code.blank? || name_changed?) }

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

  private

  # Generate code from Vietnamese name
  # Example: "Miền Bắc" -> "mien_bac"
  def generate_code_from_name
    return if name.blank?

    # Vietnamese character mapping
    vietnamese_map = {
      "à" => "a", "á" => "a", "ả" => "a", "ã" => "a", "ạ" => "a",
      "ă" => "a", "ằ" => "a", "ắ" => "a", "ẳ" => "a", "ẵ" => "a", "ặ" => "a",
      "â" => "a", "ầ" => "a", "ấ" => "a", "ẩ" => "a", "ẫ" => "a", "ậ" => "a",
      "đ" => "d",
      "è" => "e", "é" => "e", "ẻ" => "e", "ẽ" => "e", "ẹ" => "e",
      "ê" => "e", "ề" => "e", "ế" => "e", "ể" => "e", "ễ" => "e", "ệ" => "e",
      "ì" => "i", "í" => "i", "ỉ" => "i", "ĩ" => "i", "ị" => "i",
      "ò" => "o", "ó" => "o", "ỏ" => "o", "õ" => "o", "ọ" => "o",
      "ô" => "o", "ồ" => "o", "ố" => "o", "ổ" => "o", "ỗ" => "o", "ộ" => "o",
      "ơ" => "o", "ờ" => "o", "ớ" => "o", "ở" => "o", "ỡ" => "o", "ợ" => "o",
      "ù" => "u", "ú" => "u", "ủ" => "u", "ũ" => "u", "ụ" => "u",
      "ư" => "u", "ừ" => "u", "ứ" => "u", "ử" => "u", "ữ" => "u", "ự" => "u",
      "ỳ" => "y", "ý" => "y", "ỷ" => "y", "ỹ" => "y", "ỵ" => "y"
    }

    # Convert to ASCII, lowercase, replace spaces with underscores
    result = name.downcase
    vietnamese_map.each { |vn, ascii| result = result.gsub(vn, ascii) }
    result = result.gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, "_")

    self.code = result
  end
end
