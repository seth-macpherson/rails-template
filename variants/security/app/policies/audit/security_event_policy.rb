module Audit
  class SecurityEventPolicy < ReadOnlyPolicy
    def index?
      any_role? :admin, :superuser
    end
  end
end
