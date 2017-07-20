# frozen_string_literal: true
FactoryGirl.define do
  factory :version, class: PaperTrail::Version do
    event "create"
    item { create :person }
    object_changes <<~YAML
       ---
       id:
       -
       - 2
       first_name:
       -
       - Reginald
       last_name:
       -
       - Linux
       email:
       -
       - 'reggie@example.org'
       phone:
       -
       - ''
       created_at:
       -
       - 2017-07-19 22:17:44.695716000 Z
    YAML
  end
end
