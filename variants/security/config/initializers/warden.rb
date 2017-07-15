# We're using Devise to manage authentication, sign ins and outs
# Devise is built on Warden which actually manages the security
# inside the application.
#
# Setup callbacks for the authentication and logout events so that
# we can log these events to a table. It's good to keep a record of this.
Warden::Manager.after_authentication do |user, auth, _opts|
  Rails.logger.info "Authenticated #{user.inspect}"
  next if ENV.fetch("AUDIT_SECURITY_EVENTS", "true") == "false"
  log_type = auth.winning_strategy.try(:log_type) || :event
  if log_type == :event
    Audit::SecurityEvent.create(
      user:       user,
      event_type: :login,
      ip:         auth.request.remote_ip,
      user_agent: auth.request.user_agent
    )
  elsif log_type == :last_seen
    user.update_column :last_seen, Time.now
  end
end

Warden::Manager.before_logout do |user, auth, _opts|
  Rails.logger.info "Logging-out #{user.inspect}"
  next if ENV.fetch("AUDIT_SECURITY_EVENTS", "true") == "false"
  Audit::SecurityEvent.create(
    user:       user,
    event_type: :logout,
    ip:         auth.request.remote_ip,
    user_agent: auth.request.user_agent
  )
end
