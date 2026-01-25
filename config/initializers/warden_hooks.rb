# frozen_string_literal: true

# TASK-014: Log Authentication Activities
Warden::Manager.after_set_user do |user, auth, opts|
  scope = opts[:scope]
  if scope == :user && !auth.request.env['devise.skip_trackable']
    # Log login success
    ActivityLog.create!(
      user: user,
      action: 'login',
      subject: user,
      details: { method: 'database_authenticatable' },
      ip_address: auth.request.remote_ip,
      user_agent: auth.request.user_agent
    )
  end
end

Warden::Manager.before_logout do |user, auth, opts|
  scope = opts[:scope]
  if scope == :user
    # Log logout
    ActivityLog.create!(
      user: user,
      action: 'logout',
      subject: user,
      ip_address: auth.request.remote_ip,
      user_agent: auth.request.user_agent
    )
  end
end
