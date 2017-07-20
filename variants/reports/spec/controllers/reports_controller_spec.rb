# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
  let(:valid_attributes) { attributes_for :report }

  let(:invalid_attributes) do
    { title: nil }
  end

  let(:new_attributes) do
    { title: Faker::Company.name }
  end

  it_behaves_like 'a resource controller'
end
