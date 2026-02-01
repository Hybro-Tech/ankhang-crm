# frozen_string_literal: true

# TASK-014: Log Authentication Activities via Warden callbacks
# Handles login success and logout
# Failed login logging is handled by CustomFailureApp (lib/custom_failure_app.rb)

# Log successful login - ONLY when user actually authenticates (not session restore)
Warden::Manager.after_set_user do |user, auth, opts|
  scope = opts[:scope]
  event = opts[:event]

  # Only log on actual authentication, NOT on session fetch (page refresh)
  # :authentication = user just logged in with credentials
  # :fetch = user loaded from existing session
  # :set_user = manual set (e.g., after password change)
  next unless scope == :user && event == :authentication
  next if auth.request.env["devise.skip_trackable"]

  ActivityLog.create!(
    user: user,
    user_name: user.name,
    action: "login",
    category: "authentication",
    subject: user,
    details: { method: "password", status: "success" },
    ip_address: auth.request.remote_ip,
    user_agent: auth.request.user_agent
  )
end

# Log logout
Warden::Manager.before_logout do |user, auth, opts|
  scope = opts[:scope]
  next unless scope == :user && user.present?

  ActivityLog.create!(
    user: user,
    user_name: user.name,
    action: "logout",
    category: "authentication",
    subject: user,
    ip_address: auth.request.remote_ip,
    user_agent: auth.request.user_agent
  )
end
