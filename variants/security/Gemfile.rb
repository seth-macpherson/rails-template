insert_into_file "Gemfile", :after => /gem "bcrypt".*\n/ do
  <<-GEMS.strip_heredoc
    gem "devise", "~> 4.3.0"
    gem "rolify", "~> 5.1"
    gem "pundit", "~> 1.1.0"
  GEMS
end
