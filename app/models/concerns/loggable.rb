# frozen_string_literal: true

# TASK-LOGGING: Loggable concern for automatic CRUD activity logging
# Include in models to auto-log create, update, destroy actions
#
# Usage:
#   class Contact < ApplicationRecord
#     include Loggable
#     loggable category: 'contact'
#   end
#
module Loggable
  extend ActiveSupport::Concern

  included do
    class_attribute :loggable_options, default: {}

    after_create :log_create_activity
    after_update :log_update_activity
    after_destroy :log_destroy_activity
  end

  class_methods do
    # Configure logging options
    # @param category [String] Category for grouping logs (contact, user, etc.)
    # @param only [Array] Only log these actions (default: all)
    # @param except [Array] Skip these actions
    # @param track_fields [Array] Only track changes to these fields (default: all)
    # @param skip_fields [Array] Skip tracking these fields
    def loggable(category:, only: nil, except: nil, track_fields: nil, skip_fields: nil)
      self.loggable_options = {
        category: category,
        only: only,
        except: except,
        track_fields: track_fields,
        skip_fields: (default_skip_fields + Array(skip_fields)).uniq
      }
    end

    def default_skip_fields
      %w[created_at updated_at encrypted_password reset_password_token
         reset_password_sent_at remember_created_at confirmation_token
         confirmed_at confirmation_sent_at unconfirmed_email]
    end
  end

  private

  def log_create_activity
    return unless should_log?(:create)

    create_activity_log(
      action: "#{model_category}.create",
      record_changes: { new: loggable_attributes }
    )
  end

  def log_update_activity
    return unless should_log?(:update)
    return if trackable_changes.empty?

    create_activity_log(
      action: "#{model_category}.update",
      record_changes: { old: previous_values, new: current_values }
    )
  end

  def log_destroy_activity
    return unless should_log?(:destroy)

    create_activity_log(
      action: "#{model_category}.destroy",
      record_changes: { old: loggable_attributes }
    )
  end

  def create_activity_log(action:, record_changes:)
    current_user = Current.user

    ActivityLog.create!(
      user: current_user,
      user_name: current_user&.name,
      action: action,
      category: model_category,
      subject: self,
      record_changes: record_changes,
      ip_address: Current.ip_address,
      user_agent: Current.user_agent,
      request_id: Current.request_id
    )
  rescue StandardError => e
    # Don't fail the main operation if logging fails
    Rails.logger.error("[Loggable] Failed to create activity log: #{e.message}")
  end

  def should_log?(action)
    options = loggable_options
    return false if options[:only]&.exclude?(action)
    return false if options[:except]&.include?(action)

    true
  end

  def model_category
    loggable_options[:category] || self.class.name.underscore
  end

  def trackable_changes
    skip_fields = loggable_options[:skip_fields] || []
    track_fields = loggable_options[:track_fields]

    changes = saved_changes.except(*skip_fields)
    changes = changes.slice(*track_fields) if track_fields.present?
    changes
  end

  def previous_values
    trackable_changes.transform_values(&:first)
  end

  def current_values
    trackable_changes.transform_values(&:last)
  end

  def loggable_attributes
    skip_fields = loggable_options[:skip_fields] || []
    track_fields = loggable_options[:track_fields]

    attrs = attributes.except(*skip_fields)
    attrs = attrs.slice(*track_fields) if track_fields.present?
    attrs
  end
end
