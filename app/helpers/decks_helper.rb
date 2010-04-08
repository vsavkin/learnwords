module DecksHelper
  def repeat_date_output(date)
    if Time.now > date
      "right now"
    else
      "repeat in #{distance_of_time_in_words_to_now(date)}"
    end
  end
end
