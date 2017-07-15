module UIHelper
  def display_sidebar?
    user_signed_in?
  end

  def display_user_menu?
    user_signed_in?
  end
end
