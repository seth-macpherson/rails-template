class UserDecorator < ApplicationDecorator
  delegate_all
  decorates_association :security_events

  def primary_description
    object.email
  end

  def secondary_description
    [object.disabled? ? '(DISABLED)' : nil, roles_list].compact.join(' ')
  end

  def roles_list
    object.roles.pluck(:name).map(&:titleize).join(', ')
  end
end
