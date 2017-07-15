source_paths.unshift(File.dirname(__FILE__))

insert_into_file "Gemfile", after: /gem "sass-rails".*\n/ do
  <<-GEMS.strip_heredoc
    gem "semantic-ui-sass", "~> 2.2.10.1"
  GEMS
end

copy_file "app/assets/javascripts/semantic_ui_components.js"
copy_file "app/assets/javascripts/semantic_ui_initializers.es6"
copy_file "app/assets/stylesheets/semantic_ui_components.scss"
copy_file "app/helpers/ui_helper.rb"
copy_file "app/views/layouts/application.html.slim", force: true
copy_file "app/views/layouts/shared/_page_header.html.slim"
copy_file "app/views/layouts/shared/_flash.html.slim", force: true
copy_file "app/views/layouts/shared/_navigation.html.slim"
copy_file "app/views/layouts/shared/_navigation_top.html.slim"
directory "app/views/shared"
directory "app/inputs"
directory "lib/templates/slim"
