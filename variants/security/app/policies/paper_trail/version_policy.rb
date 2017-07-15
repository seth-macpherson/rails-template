class PaperTrail::VersionPolicy < ReadOnlyPolicy
  def index?
    any_role? :admin, :superuser
  end
end
