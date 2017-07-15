require 'rspec/expectations'

# Determines if the class includes the given module
RSpec::Matchers.define :include_module do |expected|
  match do |actual|
    actual.class.included_modules.include? expected
  end
end

# Checks to see if this module includes any modules from the given namespace
# e.g.) 'ActiveRecord', 'FriendlyId'
RSpec::Matchers.define :include_from_namespace do |expected|
  match do |actual|
    actual.class.included_modules.map(&:to_s).grep(/\A#{Regexp.escape expected}/).any?
  end
end
