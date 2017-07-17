FactoryGirl.define do
  factory :report do
    title { Faker::Company.bs.titleize }
    query 'SELECT COUNT(*) FROM observations'
    chart_type { %w(bar line).sample }
  end
end
