# frozen_string_literal: true
FactoryGirl.define do
  factory :security_event, class: "Audit::SecurityEvent" do
    user
    event_type :login
    ip { Faker::Internet.ip_v4_address }
    user_agent do
      YAML.load_file(Rails.root.join("spec", "fixtures", "user_agents.yml")).values.sample
    end
  end
end
