# typed: strict
# frozen_string_literal: true

require "administrate/base_dashboard"

class AuthorityDashboard < Administrate::BaseDashboard
  extend T::Sig

  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = T.let({
    id: Field::Number,
    applications: Field::HasMany,
    comments: Field::HasMany,
    disabled: YesNoBooleanField,
    email: Field::String,
    full_name: Field::String,
    github_issue: Field::HasOne,
    last_scraper_run_log: Field::Text,
    morph_name: Field::String,
    population_2017: Field::Number,
    scraper_authority_label: Field::String,
    short_name: Field::String,
    state: Field::String,
    website_url: UrlField,
    wikidata_id: Field::String
  }.freeze, T::Hash[Symbol, T.untyped])

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = T.let(%i[
    full_name
    state
    email
  ].freeze, T::Array[Symbol])

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = T.let(%i[
    full_name
    short_name
    state
    email
    wikidata_id
    website_url
    population_2017
    morph_name
    scraper_authority_label
    disabled
    last_scraper_run_log
  ].freeze, T::Array[Symbol])

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = T.let(%i[
    full_name
    short_name
    state
    email
    wikidata_id
    website_url
    population_2017
    morph_name
    scraper_authority_label
    disabled
  ].freeze, T::Array[Symbol])

  FORM_ATTRIBUTES_EDIT = T.let(%i[
    full_name
    state
    email
    wikidata_id
    website_url
    population_2017
    morph_name
    scraper_authority_label
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
  COLLECTION_FILTERS = T.let({
    active: ->(resources) { resources.active },
    disabled: ->(resources) { resources.where(disabled: true) },
    # TODO: This is only needed temporarily while we're filling out the data. Get rid of it when we can.
    empty_wikidata: ->(resources) { resources.active.where(wikidata_id: nil) }
  }.freeze, T::Hash[Symbol, T.untyped])

  # Overwrite this method to customize how authorities are displayed
  # across all pages of the admin dashboard.

  sig { params(authority: Authority).returns(String) }
  def display_resource(authority)
    authority.full_name
  end
end
