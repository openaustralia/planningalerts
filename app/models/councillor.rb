class Councillor < ActiveRecord::Base
  has_many :comments
  has_many :replies
  belongs_to :authority

  validates :authority, presence: true
  validates :image_url, format: { with: /\Ahttps/, message: "must be HTTPS" }, allow_blank: true

  def prefixed_name
    "local councillor #{name}"
  end
end
