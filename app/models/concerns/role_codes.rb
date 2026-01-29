# frozen_string_literal: true

# RBAC Refactoring: Role code constants
# These constants should be used instead of hardcoding role code strings
# to prevent issues when admin changes role codes
module RoleCodes
  extend ActiveSupport::Concern

  # System role codes - NEVER change these without migration
  SUPER_ADMIN = "super_admin"
  SALE = "sale"
  CALL_CENTER = "call_center"
  CSKH = "cskh"

  # All system role codes
  ALL_CODES = [SUPER_ADMIN, SALE, CALL_CENTER, CSKH].freeze

  # Dashboard type mapping for convenience
  DASHBOARD_TYPES = {
    SUPER_ADMIN => :admin,
    SALE => :sale,
    CALL_CENTER => :call_center,
    CSKH => :cskh
  }.freeze
end
