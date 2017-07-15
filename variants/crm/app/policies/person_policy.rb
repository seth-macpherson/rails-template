class PersonPolicy < ApplicationPolicy
  def show?
    user.present?
  end

  def create_user?
    UserPolicy.new(user, nil).create?
  end

  def update?
    super || (user.present? && record == user.person)
  end

  def permitted_attributes
    %i(first_name last_name email phone born_on)
  end
end
