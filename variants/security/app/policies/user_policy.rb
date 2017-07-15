class UserPolicy < ApplicationPolicy
  def index?
    any_role? :superuser, :admin
  end

  def show?
    super || (user.present? && record == user)
  end

  def send_reset_password?
    any_role? :superuser, :admin
  end

  def permitted_attributes
    [:person_id, :email, :password, :password_confirmation, :disabled, role_ids: []]
  end

  def permitted_update_attributes
    permitted_attributes - %i(person_id email)
  end

  def permitted_export_attributes
    super - %i(encrypted_password reset_password_token reset_password_sent_at remember_created_at current_sign_in_at)
  end
end
