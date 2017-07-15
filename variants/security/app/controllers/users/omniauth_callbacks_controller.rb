module Users
  # Handles omniauth authentication. Providers need to redirect back to us
  # with authentication information in the GET, POST, or headers. This
  # controller handles the responses from OAuth providers
  class OmniauthCallbacksController < ::Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    # The oauth provider returns the user here after authentication
    def generic_callback
      auth = request.env['omniauth.auth']
      Rails.logger.debug "Got OAuth response: #{auth}"

      authenticator = OmniauthAuthenticator.new(auth)

      if authenticator.new_identity?
        # This is a new user to us. Someone that clicked "Sign-up with Facebook"
        # for example. So, we need to create their Person and User records
        authenticator.persist_user!
      end

      # Call remember_me to persist this login across browser sessions
      remember_me authenticator.user

      sign_in_and_redirect authenticator.user, event: :authentication
    end

    # We need to alias the callback for every omniauth provider that is setup
    alias facebook generic_callback

    def failure
      strategy = request.env['omniauth.strategy'].name
      Rails.logger.debug "An attempted login via #{strategy} failed"
      super
    end
  end
end
