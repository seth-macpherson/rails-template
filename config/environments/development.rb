mailer_regex = /config\.action_mailer\.raise_delivery_errors = false\n/

comment_lines "config/environments/development.rb", mailer_regex
insert_into_file "config/environments/development.rb", after: mailer_regex do
  <<-RUBY

  # Ensure mailer works in development.
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: "localhost:3000" }
  config.action_mailer.asset_host = "http://localhost:3000"
  RUBY
end

insert_into_file "config/environments/development.rb", before: /^end/ do
  <<-RUBY

  # Setup bullet to track N+1 errors
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = false        # JavaScript alert()
    Bullet.console = true       # Logs to browser console
    Bullet.bullet_logger = true # log/bullet.log
    Bullet.rails_logger = true  # Standard logger
    Bullet.add_footer = true    # Adds unobtrusive footer to the page when needed
  end
  RUBY
end

insert_into_file "config/environments/development.rb", before: /^end/ do
  <<-RUBY

  # Automatically inject JavaScript needed for LiveReload.
  config.middleware.insert_after(ActionDispatch::Static, Rack::LiveReload)
  RUBY
end
