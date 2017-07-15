module Users
  # Simple override for the default sessions controller to delete the flash
  # messages where they're really not neeed. We know if signing in or out worked
  class SessionsController < Devise::SessionsController
    # POST /resource/sign_in
    def create
      super
      flash.delete(:notice)
    end
  end
end
