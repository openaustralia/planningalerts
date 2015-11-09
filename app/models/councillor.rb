class Councillor < ActiveRecord::Base
  has_many :comments
  has_many :replies
  belongs_to :authority

  validates :authority, presence: true

  def display_name
    "local councillor #{name}"
  end
end
