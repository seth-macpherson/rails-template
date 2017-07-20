Rails.application.config.generators do |g|
  # Disable generators we don't need.
  g.javascripts         false
  g.stylesheets         false
  g.jbuilder            false
  g.helper              false
  g.scaffold_stylesheet false
  g.view_specs          false
  g.system_tests        false
end
