source_paths.unshift(File.dirname(__FILE__))

apply "Gemfile.rb"
apply "config/template.rb"
apply "app/template.rb"
directory "spec"

append_to_file "example.env", "DEVISE_SENDER=change-this@#{app_name.parameterize}.example.com\n"

omniauth_providers = {
  facebook:      { gem: '"omniauth-facebook", "~> 4.0"',      name: "Facebook", env_key: "FACEBOOK" },
  google_oauth2: { gem: '"omniauth-google-oauth2", "~> 0.5"', name: "Google",   env_key: "GOOGLE" },
  github:        { gem: '"omniauth-github", "~> 1.3"',        name: "GitHub",   env_key: "GITHUB" }
}
configured_providers = []
omniauth_providers.each do |key, spec|
  next unless yes? "Add omniauth support for #{spec[:name]}? [y/n]"
  insert_into_file "Gemfile", "gem #{spec[:gem]}\n", after: /gem "devise".*\n/
  insert_into_file "config/initializers/devise.rb",
                    %|  config.omniauth :#{key}, ENV["#{spec[:env_key]}_APP_ID"], ENV["#{spec[:env_key]}_APP_SECRET"]\n|,
                    after: /# config.omniauth :github.+\n/
  append_to_file "example.env", "#{spec[:env_key]}_APP_ID=\n"
  append_to_file "example.env", "#{spec[:env_key]}_APP_SECRET=\n"
  configured_providers << key
end

migration "db/migrate/create_users.rb"
migration "db/migrate/create_identities.rb"
migration "db/migrate/create_user_roles.rb"
migration "db/migrate/create_audit_security_events.rb"

route <<-RUBY
  devise_for :users, controllers: {
    confirmations:      "users/confirmations",
    registrations:      "users/registrations",
    sessions:           "users/sessions"
  }
  resources :users do
    member do
      get :send_reset_password
    end
  end
RUBY

insert_into_file  "config/routes.rb",
                  "    resources :security_events, only: :index\n",
                  after: /namespace :audit.+\n/

insert_into_file  "app/controllers/home_controller.rb",
                  "    authorize :home, :show?\n",
                  after: /def show\n/

unless configured_providers.empty?
  copy_file "app/controllers/users/omniauth_callbacks_controller.rb"
  insert_into_file "config/routes.rb",
                    "    omniauth_callbacks: 'users/omniauth_callbacks',\n",
                    after: /devise_for :users.+\n/
  insert_into_file  "app/models/user.rb",
                    ",\n         :omniauthable, omniauth_providers: Devise.omniauth_providers",
                    after: /:validatable(?=\n)/m
end
