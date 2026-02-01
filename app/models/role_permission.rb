# frozen_string_literal: true

# == Schema Information
#
# Table name: role_permissions
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  permission_id :bigint           not null
#  role_id       :bigint           not null
#
# Indexes
#
#  index_role_permissions_on_permission_id              (permission_id)
#  index_role_permissions_on_role_id                    (role_id)
#  index_role_permissions_on_role_id_and_permission_id  (role_id,permission_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (permission_id => permissions.id)
#  fk_rails_...  (role_id => roles.id)
#
class RolePermission < ApplicationRecord
  include Loggable

  belongs_to :role
  belongs_to :permission

  validates :role_id, uniqueness: { scope: :permission_id, message: "đã có quyền này" }
end

#------------------------------------------------------------------------------
# RolePermission
#
# Name          SQL Type             Null    Primary Default
# ------------- -------------------- ------- ------- ----------
# id            bigint               false   true
# role_id       bigint               false   false
# permission_id bigint               false   false
# created_at    datetime(6)          false   false
# updated_at    datetime(6)          false   false
#
#------------------------------------------------------------------------------
