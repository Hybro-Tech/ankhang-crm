# frozen_string_literal: true

# == Schema Information
#
# Table name: user_permissions
#
#  id            :bigint           not null, primary key
#  granted       :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint
#  permission_id :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_user_permissions_on_created_by_id              (created_by_id)
#  index_user_permissions_on_permission_id              (permission_id)
#  index_user_permissions_on_user_id                    (user_id)
#  index_user_permissions_on_user_id_and_permission_id  (user_id,permission_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (permission_id => permissions.id)
#  fk_rails_...  (user_id => users.id)
#
class UserPermission < ApplicationRecord
  belongs_to :user
  belongs_to :permission

  validates :user_id, uniqueness: { scope: :permission_id }
  validates :granted, inclusion: { in: [true, false] }
end

#------------------------------------------------------------------------------
# UserPermission
#
# Name          SQL Type             Null    Primary Default
# ------------- -------------------- ------- ------- ----------
# id            bigint               false   true
# user_id       bigint               false   false
# permission_id bigint               false   false
# granted       tinyint(1)           true    false   1
# created_at    datetime(6)          false   false
# updated_at    datetime(6)          false   false
# created_by_id bigint               true    false
#
#------------------------------------------------------------------------------
