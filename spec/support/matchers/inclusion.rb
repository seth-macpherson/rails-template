require 'rspec/expectations'

# Reverse syntax of include
# e.g. expect(Person.role).to be_included_in ['admin', 'user', 'guest']
RSpec::Matchers.define :be_included_in do |expected|
  match do |actual|
    expected.include? actual
  end

  failure_message do |actual|
    %(expected "#{actual}" to be included in "#{expected}")
  end
end
