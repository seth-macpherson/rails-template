copy_file "spec/rails_helper.rb", force: true
copy_file "spec/spec_helper.rb", force: true
copy_file "spec/support/bullet.rb"
copy_file "spec/support/capybara.rb"
copy_file "spec/support/devise.rb"
copy_file "spec/support/factory_girl.rb"
copy_file "spec/support/paper_trail.rb"
copy_file "spec/support/shoulda_matchers.rb"
copy_file "spec/support/warden.rb"

copy_file "spec/support/core_extensions/hash.rb"

copy_file "spec/support/helpers/jsonapi.rb"
copy_file "spec/support/helpers/security.rb"

copy_file "spec/support/matchers/friendly_id.rb"
copy_file "spec/support/matchers/inclusion.rb"
copy_file "spec/support/matchers/reflection.rb"

copy_file "spec/support/shared_examples/acts_as_list_examples.rb"
copy_file "spec/support/shared_examples/basic_request_examples.rb"
copy_file "spec/support/shared_examples/friendly_id_examples.rb"
copy_file "spec/support/shared_examples/indestructible_model_examples.rb"
copy_file "spec/support/shared_examples/paranoia_examples.rb"
copy_file "spec/support/shared_examples/pundit_examples.rb"
copy_file "spec/support/shared_examples/resource_controller_examples.rb"
