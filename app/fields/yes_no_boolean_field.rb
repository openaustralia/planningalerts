require "administrate/field/base"

class YesNoBooleanField < Administrate::Field::Base
  def to_s
    if data.nil?
      "-"
    elsif data
      "yes"
    else
      "no"
    end
  end
end
