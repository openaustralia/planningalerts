module SignupHelper
  def meters_in_words_as_array(meters)
    if meters < 1000
      [meters, "m"]
    else
      [meters / 1000, "km"]
    end
  end
  
  def meters_in_words(meters)
    meters_in_words_as_array(meters).join(" ")
  end
  
  # TODO: Get rid of this helper so that we format distances consistently
  def meters_in_words_no_space(meters)
    meters_in_words_as_array(meters).join
  end
end
