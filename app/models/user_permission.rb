# frozen_string_literal: true

class UserPermission < ApplicationRecord
  belongs_to :user
  belongs_to :permission

  validates :user_id, uniqueness: { scope: :permission_id }
  validates :granted, inclusion: { in: [true, false] }
end
