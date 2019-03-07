# frozen_string_literal: true

class Councillor < ApplicationRecord
  has_many :comments, dependent: :restrict_with_error
  has_many :replies, dependent: :restrict_with_error
  belongs_to :authority

  validates :authority, :email, presence: true
  validates :image_url, format: { with: /\Ahttps.*\z/, message: "must be HTTPS" }, allow_blank: true

  def initials
    first_letters = name.split(/\s/).collect { |word| word.first.upcase }
    first_letters = first_letters.values_at(0, -1) unless first_letters.one?
    first_letters.join(" ")
  end

  def prefixed_name
    "local councillor #{name}"
  end

  def writeit_id
    authority.popolo_url + "/person/" + popolo_id
  end

  def cached_image_url
    "https://australian-local-councillors-images.s3.amazonaws.com/#{popolo_id}-80x88.jpg"
  end

  def cached_image_available?
    uri = URI(cached_image_url)

    request = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |https|
      https.request_head(uri.path)
    end

    request.is_a? Net::HTTPSuccess
  end
end
