source_paths.unshift(File.dirname(__FILE__))

insert_into_file "Gemfile", after: /gem "bcrypt".*\n/ do
  <<-GEMS.strip_heredoc
    gem "chartkick"
  GEMS
end

run "yard add codemirror"

migration "db/migrate/create_reports.rb"

directory "app"
directory "spec"

route <<-RUBY
  resources :reports do
    member do
      get :data
    end
    collection do
      post :preview
    end
  end
RUBY
