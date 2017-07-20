# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'People', type: :request, model: :person do
  it_behaves_like 'basic request actions'
end
