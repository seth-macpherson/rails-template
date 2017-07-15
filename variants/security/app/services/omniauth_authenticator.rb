# Service object to handling authentication from OmniAuth to slim-down the
# controller. Handles the finding or creation of People, users, and Identities
# from an omniauth response
class OmniauthAuthenticator
  # auth: Comes from the request.env['omniauth.auth']
  def initialize(auth)
    @auth = auth
  end

  def persist_user!
    user.identities.push identity

    # Calling save on user will persist the person as well
    user.save!
  end

  def new_identity?
    !identity.persisted?
  end

  def identity
    @identity ||= Identity.from_oauth(@auth)
  end

  # Tries to find a person record with an email address matching the one
  # returned from the omniauth provider. If none was found, a new person is
  # initialised with the basic information from the provider
  def person
    @person ||= Person.find_or_initialize_by email: @auth[:info][:email] do |p|
      if %i(first_name last_name).all? { |f| @auth[:info].key? f }
        # If the oauth provider gave us first and last name, use them
        p.first_name = @auth[:info][:first_name]
        p.last_name = @auth[:info][:last_name]
      else
        p.name = @auth[:info][:name]
      end
    end
  end

  def user
    @user ||= User.find_or_initialize_by person: person do |a|
      a.email = @auth[:info][:email]

      # Generate a random password for the user
      a.password = Devise.friendly_token[0, 20]

      # Since the user is coming from omniauth there's no need to confirm their email
      a.skip_confirmation!

      # Default the new user to have the 'guest' role
      a.add_role :guest
    end
  end
end
