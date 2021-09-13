# typed: true
# frozen_string_literal: true

# Comment form object
class AddComment
  include ActiveModel::Model
  extend ActiveModel::Validations::ClassMethods

  attr_accessor(
    :name,
    :text,
    :address,
    :email,
    :comment_for,
    :application
  )

  validates :name, presence: true
  validates :text, presence: true
  validates :email, presence: true
  validates :address, presence: true
  validates_email_format_of :email

  def save_comment
    return unless valid?

    @comment = Comment.new(
      application_id: application.id,
      name: name,
      text: text,
      address: address,
      email: email
    )
    @comment if @comment.save
  end
end
