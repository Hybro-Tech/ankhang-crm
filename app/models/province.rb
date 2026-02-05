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

  # Callbacks - Auto-generate code from name
  before_validation :generate_code_from_name, if: -> { name.present? && (code.blank? || name_changed?) }

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

  private

  # Generate code from Vietnamese name
  # Example: "Thành phố Hà Nội" -> "THANH_PHO_HA_NOI"
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

    # Convert to ASCII, uppercase, replace spaces with underscores
    result = name.downcase
    vietnamese_map.each { |vn, ascii| result = result.gsub(vn, ascii) }
    result = result.gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, "_").upcase

    self.code = result
  end
end
