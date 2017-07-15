insert_into_file  "app/controllers/application_controller.rb",
                  "  include Pundit\n\n",
                  after: /^class ApplicationController.*\n/

insert_into_file  "app/controllers/application_controller.rb", after: /protect_from_forgery.*\n/ do
  <<-RUBY

  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit

  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?
  RUBY
end

directory "app/controllers"
directory "app/decorators"
directory "app/helpers"
directory "app/models"
directory "app/policies"
directory "app/services"
directory "app/views"

uncomment_lines "app/models/person.rb", /has_one :user/
uncomment_lines "app/models/person.rb", /before_destroy :ensure_no_user/
