# For records like logs that should never be modified directly, this policy
# has you covered
class ReadOnlyPolicy < ApplicationPolicy
  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end
end
