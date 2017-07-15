insert_into_file "config/application.rb", after: /Rails::Application\n/ do
  <<-'RUBY'
    # Views and functions can't be preserved in a schema file. Has to be SQL
    config.active_record.schema_format = :sql
  RUBY
end
