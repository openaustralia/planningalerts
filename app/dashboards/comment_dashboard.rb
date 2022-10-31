# typed: strict
# frozen_string_literal: true

require "administrate/base_dashboard"

class CommentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = T.let({
    application: Field::BelongsTo,
    reports: Field::HasMany,
    id: Field::Number,
    text: Field::Text,
    user: Field::BelongsTo,
    name: Field::String,
    confirm_id: Field::String,
    confirmed: YesNoBooleanField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    address: Field::String,
    hidden: YesNoBooleanField,
    confirmed_at: Field::DateTime,
    last_delivered_at: Field::DateTime,
    last_delivered_successfully: YesNoBooleanField
  }.freeze, T::Hash[Symbol, T.untyped])

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = T.let(%i[
    created_at
    application
    text
    name
  ].freeze, T::Array[Symbol])

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = T.let(%i[
    application
    text
    user
    name
    confirm_id
    confirmed
    created_at
    updated_at
    address
    hidden
    confirmed_at
    last_delivered_at
    last_delivered_successfully
    reports
  ].freeze, T::Array[Symbol])

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = T.let(%i[
    text
    name
    address
    hidden
  ].freeze, T::Array[Symbol])

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = T.let({
    visible: ->(resources) { resources.visible },
    hidden: ->(resources) { resources.where(hidden: true) }
  }.freeze, T::Hash[Symbol, T.untyped])

  # Overwrite this method to customize how comments are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(comment)
  #   "Comment ##{comment.id}"
  # end
end
