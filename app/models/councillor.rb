class Councillor < ActiveRecord::Base
  has_many :comments
  has_many :replies
  belongs_to :authority

  def display_name
    "local councillor #{name}"
  end
end
