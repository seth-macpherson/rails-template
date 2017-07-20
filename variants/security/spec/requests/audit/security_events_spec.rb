# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Security Events", type: :request do
  before(:each) do
    sign_in_stubbed
  end

  describe "#index" do
    before do
      create(:security_event)
      get audit_security_events_path
    end
    subject { response }
    it { is_expected.to have_http_status :success }
  end
end
