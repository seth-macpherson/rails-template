source_paths.unshift(File.dirname(__FILE__))

migration "db/migrate/0001_create_people.rb"

directory "app"
directory "spec"

route "resources :people"
