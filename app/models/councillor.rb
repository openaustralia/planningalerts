class Councillor < ActiveRecord::Base
  has_many :comments, dependent: :restrict_with_error
  has_many :replies, dependent: :restrict_with_error
  belongs_to :authority

  validates :authority, :email, presence: true
  validates :image_url, format: { with: /\Ahttps/, message: "must be HTTPS" }, allow_blank: true

  def prefixed_name
    "local councillor #{name}"
  end

  def writeit_id
    authority.popolo_url + "/person/" + popolo_id
  end

  def cached_image_url
    "https://australian-local-councillors-images.s3.amazonaws.com/#{popolo_id}.jpg"
  end
end
