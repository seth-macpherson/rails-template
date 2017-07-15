class UsersController < BaseResourcesController
  eager_load :index, :person

  def create
    build_resource
    @user.email = @user.person.email
    super
  end

  def send_reset_password
    authorize resource
    resource.send_reset_password_instructions
    message = "Sent password reset instructions to #{resource.email}"
    respond_with resource do |format|
      format.json { render json: { success: true, message: message } }
      format.html { redirect_to resource, notice: message }
    end
  end
end
