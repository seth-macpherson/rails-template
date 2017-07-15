module Audit
  class SecurityEventsController < BaseResourcesController
    def index
      @security_events = policy_scope(Audit::SecurityEvent).includes(:user).page(params[:page]).decorate
    end
  end
end
