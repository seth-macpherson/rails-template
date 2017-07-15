module Users
  class RegistrationsController < Devise::RegistrationsController
    protected

    # Build a devise resource passing in the session. Useful to move
    # temporary session data to the newly created user.
    def build_resource(hash = nil)
      self.resource = resource_class.new_with_session(hash || {}, session)
      person_params = params.fetch(:user, {}).fetch(:person, {})
      if person_params.empty?
        self.resource.person = Person.new
      else
        self.resource.person = Person.find_or_initialize_by email: params[:user][:email] do |p|
          p.first_name = person_params[:first_name]
          p.last_name = person_params[:last_name]
        end
      end
    end

    # When a user is inactive, go directly to the signin page so the correct
    # message is displayed to the user
    def after_inactive_sign_up_path_for(resource)
      new_user_session_path
    end
  end
end
