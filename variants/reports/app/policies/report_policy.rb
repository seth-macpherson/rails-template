class ReportPolicy < ApplicationPolicy
  def show?
    super || (user.present? && record.published?)
  end

  def data?
    show?
  end

  def preview?
    create?
  end

  class Scope < Scope
    def resolve
      if user.present? && user.any_role?(:superuser, :admin)
        super
      else
        super.published
      end
    end
  end
end
