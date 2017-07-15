# Policy for the home controller. This is a 'headless' policy as in it has
# no directly related record.
class HomePolicy < Struct.new(:user, :home)
  def initialize(user, scope)
    @user = user
    @scope = scope
  end

  def show?
    true
  end

  def help?
    @user.present?
  end
end
