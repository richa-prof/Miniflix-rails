module CommentsHelper
  def profile_path_for(user)
    # Returns the Dashboard path if the logged in staff clicks on his own profile link.
    if current_staff_user.present? && (current_staff_user == user)
      root_path
    else
      profile_path(user)
    end
  end
end
