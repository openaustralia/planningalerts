class Councillor < ActiveRecord::Base
  has_many :comments
  belongs_to :authority

  def display_name
    "local councillor #{name}"
  end
end
