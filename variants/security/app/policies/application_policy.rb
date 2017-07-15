# Default authorization for the app:
# * non-authorizsed users can't do anything
# * have to be an admin to CRUD
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.present?
  end

  def show?
    any_role? :admin
  end

  def create?
    any_role? :admin
  end

  def new?
    create?
  end

  def update?
    any_role? :admin
  end

  def edit?
    update?
  end

  def destroy?
    any_role? :admin
  end

  def export?
    true
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  # Default permitted attributes for create and update
  def permitted_attributes
    record.attributes.keys.map(&:to_sym) - %i(id slug created_at updated_at deleted_at)
  end

  def permitted_new_attributes
    permitted_attributes
  end

  def permitted_create_attributes
    permitted_attributes
  end

  def permitted_update_attributes
    permitted_attributes
  end

  def permitted_export_attributes
    record.class.attribute_names.map(&:to_sym) - %i(slug legacy_id data_source)
  end

  # Defines which records a user is allowed to see when querying
  # For example, admins can see everything, but a user perhaps can
  # only see an index of bookings and payments that belong to them
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      @user.present? ? scope : scope.none
    end
  end

  protected

  def roles?
    user.present && user.roles.present?
  end

  def any_role?(*roles)
    user.present? && user.any_role?(roles)
  end

  # If the user matches the person on the record, they're considered to be
  # the owner. The default relation is :person
  # example) a Payment record with #person == user.person
  def user_is_owner?(relation = :person)
    user.present? && record.send(relation) == user.person
  end
end
