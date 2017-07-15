module Users
  class ConfirmationsController < Devise::ConfirmationsController
    # Override the #show method to automatically sign-in the user after
    # they confirm
    def show
      super do |resource|
        sign_in(resource)
      end
    end

    private

    def after_confirmation_path_for(_resource_name, resource)
      stored_location_for(resource) || signed_in_root_path
    end
  end
end
