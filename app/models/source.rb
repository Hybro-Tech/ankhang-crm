# frozen_string_literal: true

class Source < ApplicationRecord
  has_many :contacts, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc, created_at: :asc) }

  # For dropdowns
  def self.for_dropdown
    active.ordered
  end
end
