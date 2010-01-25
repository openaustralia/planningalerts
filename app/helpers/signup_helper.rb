module SignupHelper
  def meters_in_words(meters)
    if meters < 1000
      "#{meters} m"
    else
      "#{meters / 1000} km"
    end
  end
end
