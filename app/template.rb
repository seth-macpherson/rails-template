copy_file "app/assets/stylesheets/application.scss"
remove_file "app/assets/stylesheets/application.css"
copy_file "app/assets/stylesheets/devise.scss"
copy_file "app/assets/stylesheets/forms.scss"
copy_file "app/assets/stylesheets/general.scss"
copy_file "app/assets/javascripts/application.js", force: true
copy_file "app/assets/javascripts/core_helpers.js"

copy_file "app/controllers/home_controller.rb"
copy_file "app/controllers/base_resources_controller.rb"
copy_file "app/controllers/audit/versions_controller.rb"
copy_file "app/helpers/application_helper.rb", force: true
copy_file "app/helpers/layout_helper.rb"
copy_file "app/helpers/retina_image_helper.rb"
copy_file "app/views/layouts/application.html.slim", force: true
copy_file "app/views/layouts/base.html.slim"
copy_file "app/views/layouts/shared/_flash.html.slim"
copy_file "app/views/home/show.html.slim"
empty_directory_with_keep_file "app/jobs"
empty_directory_with_keep_file "app/services"

directory "app/inputs"
directory "app/decorators"

insert_into_file "app/controllers/application_controller.rb", "\n  respond_to :html, :json\n", before: /^end\n/

# we're using slim
remove_file "app/views/layouts/application.html.erb"

run "yarn add jquery"
