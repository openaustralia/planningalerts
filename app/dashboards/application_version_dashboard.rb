require "administrate/base_dashboard"

class ApplicationVersionDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    application: Field::BelongsTo,
    previous_version: Field::BelongsTo,
    id: Field::Number,
    current: Field::Boolean,
    address: Field::Text,
    description: Field::Text,
    info_url: Field::String,
    comment_url: Field::String,
    date_received: Field::Date,
    on_notice_from: Field::Date,
    on_notice_to: Field::Date,
    date_scraped: Field::DateTime,
    lat: Field::Number.with_options(decimals: 2),
    lng: Field::Number.with_options(decimals: 2),
    suburb: Field::String,
    state: Field::String,
    postcode: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    application
    previous_version
    id
    current
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    application
    previous_version
    id
    current
    address
    description
    info_url
    comment_url
    date_received
    on_notice_from
    on_notice_to
    date_scraped
    lat
    lng
    suburb
    state
    postcode
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    application
    previous_version
    current
    address
    description
    info_url
    comment_url
    date_received
    on_notice_from
    on_notice_to
    date_scraped
    lat
    lng
    suburb
    state
    postcode
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

  # Overwrite this method to customize how application versions are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(application_version)
  #   "ApplicationVersion ##{application_version.id}"
  # end
end
