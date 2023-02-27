require "administrate/field/base"

class WikidataField < Administrate::Field::Base
  def to_s
    data
  end
end
