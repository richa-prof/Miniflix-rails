module UsersHelper

  def image_cloud_front_url(path)
    url = 'https://' +  ENV['cloud_front_url'] +'/'+ path
  end

  def check_page_type(page, genre)
    (page.present?) ? "play_film_in_desc play_film_in_desc_featured" : "play-genre play-#{genre.parametrize_genre_name}"
  end

  def check_plus_symbol(page, genre)
    (page.present?) ? "" : "+"
  end

  def check_class_for_plus_symbol(page, genre)
    (page.present?) ? "watch_list watch_list_featured watch_list_left margin-bottom" : "watch-circle-genre watch-plus-genre watch-plus-#{genre.parametrize_genre_name}"
  end

  def price_rate_of_plan(plan_type)
    (plan_type == "Monthly") ? "$3.99 per month" : "$24 per year"
  end

  def caption_for_phone_number
    (current_user.phone_number.present?) ? "Edit" : "Add"
  end
end
