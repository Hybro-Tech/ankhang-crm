# frozen_string_literal: true

# == Schema Information
#
# Table name: user_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  role_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_roles_on_role_id              (role_id)
#  index_user_roles_on_user_id              (user_id)
#  index_user_roles_on_user_id_and_role_id  (user_id,role_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (role_id => roles.id)
#  fk_rails_...  (user_id => users.id)
#
class UserRole < ApplicationRecord
  include Loggable

  belongs_to :user
  belongs_to :role

  validates :user_id, uniqueness: { scope: :role_id, message: "đã có vai trò này" }
end

#------------------------------------------------------------------------------
# UserRole
#
# Name       SQL Type             Null    Primary Default
# ---------- -------------------- ------- ------- ----------
# id         bigint               false   true
# user_id    bigint               false   false
# role_id    bigint               false   false
# created_at datetime(6)          false   false
# updated_at datetime(6)          false   false
#
#------------------------------------------------------------------------------
