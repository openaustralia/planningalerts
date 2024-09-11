# typed: strict
# frozen_string_literal: true

require "administrate/base_dashboard"

class ApiKeyDashboard < Administrate::BaseDashboard
  extend T::Sig

  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = T.let({
    id: Field::Number,
    bulk: YesNoBooleanField,
    commercial: YesNoBooleanField,
    community: YesNoBooleanField,
    daily_limit: Field::Number,
    disabled: YesNoBooleanField,
    user: Field::BelongsTo,
    value: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    expires_at: Field::DateTime,
    versions: Field::PaperTrail
  }.freeze, T::Hash[Symbol, T.untyped])

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = T.let(%i[
    user
    bulk
    disabled
    commercial
    community
    daily_limit
  ].freeze, T::Array[Symbol])

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = T.let(%i[
    user
    value
    bulk
    expires_at
    disabled
    commercial
    community
    daily_limit
    created_at
    updated_at
    versions
  ].freeze, T::Array[Symbol])

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = T.let(%i[
    bulk
    commercial
    community
    daily_limit
    expires_at
    disabled
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

  # Overwrite this method to customize how api keys are displayed
  # across all pages of the admin dashboard.
  #
  sig { params(api_key: ApiKey).returns(String) }
  def display_resource(api_key)
    "ApiKey ##{api_key.id} (#{api_key.user&.email})"
  end
end
