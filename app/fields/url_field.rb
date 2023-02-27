require "administrate/field/base"

class UrlField < Administrate::Field::Base
  def to_s
    data
  end
end
