# typed: strict
# frozen_string_literal: true

require "administrate/base_dashboard"

class ApplicationDashboard < Administrate::BaseDashboard
  extend T::Sig

  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = T.let({
    authority: Field::BelongsTo,
    comments: Field::HasMany,
    versions: Field::HasMany,
    current_version: Field::HasOne,
    first_version: Field::HasOne,
    id: Field::Number,
    council_reference: Field::String,
    no_alerted: Field::Number,
    visible_comments_count: Field::Number,
    address: Field::Text,
    description: Field::Text,
    info_url: Field::String.with_options(searchable: false),
    lat: Field::Number.with_options(decimals: 2),
    lng: Field::Number.with_options(decimals: 2),
    date_scraped: Field::DateTime,
    date_received: Field::Date,
    suburb: Field::String.with_options(searchable: false),
    postcode: Field::String.with_options(searchable: false),
    on_notice_from: Field::Date,
    on_notice_to: Field::Date
  }.freeze, T::Hash[Symbol, T.untyped])

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = T.let(%i[
    council_reference
    authority
  ].freeze, T::Array[Symbol])

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = T.let(%i[
    id
    council_reference
    address
    description
    info_url
    authority
    lat
    lng
    date_scraped
    date_received
    suburb
    postcode
    on_notice_from
    on_notice_to
    no_alerted
    comments
  ].freeze, T::Array[Symbol])

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = T.let(%i[
    authority
    comments
    versions
    current_version
    first_version
    council_reference
    no_alerted
    visible_comments_count
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
  COLLECTION_FILTERS = T.let({}.freeze, T::Hash[Symbol, T.untyped])

  # Overwrite this method to customize how applications are displayed
  # across all pages of the admin dashboard.
  #
  sig { params(application: Application).returns(String) }
  def display_resource(application)
    application.council_reference
  end
end
