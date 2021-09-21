# typed: true

require "administrate/base_dashboard"

class ApplicationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
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
    info_url: Field::String,
    lat: Field::Number.with_options(decimals: 2),
    lng: Field::Number.with_options(decimals: 2),
    date_scraped: Field::DateTime,
    date_received: Field::Date,
    suburb: Field::String,
    postcode: Field::String,
    on_notice_from: Field::Date,
    on_notice_to: Field::Date
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    council_reference
    authority
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
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
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    authority
    comments
    versions
    current_version
    first_version
    council_reference
    no_alerted
    visible_comments_count
  ].freeze

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
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how applications are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(application)
    application.council_reference
  end
end