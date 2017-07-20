# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PeopleController, type: :controller do
  let(:valid_attributes) { attributes_for :person }

  let(:invalid_attributes) do
    { email: nil }
  end

  let(:new_attributes) do
    { last_name: Faker::Name.last_name }
  end

  it_behaves_like 'a resource controller'
end
