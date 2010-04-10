module SignupHelper
  def draw_box_javascript(size)
    area = Area.centre_and_size(@alert.location, @zone_sizes[size])    
    "preview(#{area.lower_left.lat}, #{area.lower_left.lng}, #{area.upper_right.lat}, #{area.upper_right.lng});"
  end
end
