# Capybara + poltergeist allow JS testing via headless webkit
require "capybara/rails"
require "capybara-screenshot/rspec"
require "capybara/poltergeist"

Capybara.javascript_driver = :poltergeist
Capybara.save_and_open_page_path = ENV['CIRCLE_ARTIFACTS'] if ENV['CIRCLE_ARTIFACTS']
Capybara::Screenshot.autosave_on_failure = true
Capybara::Screenshot.append_timestamp = true

# Time to wait before Capybara gives-up looking for an item and calls it a fail
Capybara.default_max_wait_time = 5

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Ensure each test gets a clean session
  setup { Capybara.current_session.driver.browser.clear_cookies }
end

RSpec.configure do |config|
  config.before(:each, js: true) do
    # For some reason Poltergeist has a problem loading these. So, ignore them
    page.driver.browser.url_blacklist = [
      '/assets/themes/default/assets/fonts/',
      'https://fonts.googleapis.com/'
    ]
  end

  config.after(:each, type: :feature) do |example|
    missing_translations = page.body.scan(/translation missing: #{I18n.locale}\.(.*?)[\s<\"&]/)
    if missing_translations.any?
      puts "Found missing translations: #{missing_translations.inspect}"
      puts "In spec: #{example.location}"
    end
  end
end
