class PeopleController < BaseResourcesController
  def create_user
    authorize @person

    # TODO: DRY-up and move into service object
    user = @person.build_user(email: @person.email).tap do |u|
      u.password = Devise.friendly_token[0, 20]
      u.add_role :guest
    end

    if user.save
      user.send_reset_password_instructions
      respond_to do |format|
        format.html { redirect_to @person, notice: t(".notice") }
        format.json { render json: { success: true, message: t(".notice") } }
      end
    else
      message = user.errors.full_messages.join(", ")
      respond_to do |format|
        format.html { redirect_to @person, error: message }
        format.json { render json: { success: false, errors: message }, status: :unprocessable_entity }
      end
    end
  end
end
