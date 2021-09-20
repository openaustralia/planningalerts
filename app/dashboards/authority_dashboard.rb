require "administrate/base_dashboard"

class AuthorityDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    applications: Field::HasMany,
    comments: Field::HasMany,
    github_issue: Field::HasOne,
    id: Field::Number,
    full_name: Field::String,
    short_name: Field::String,
    disabled: Field::Boolean,
    state: Field::String,
    email: Field::String,
    last_scraper_run_log: Field::Text,
    morph_name: Field::String,
    website_url: Field::String,
    population_2017: Field::Number,
    scraper_authority_label: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    applications
    comments
    github_issue
    id
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    applications
    comments
    github_issue
    id
    full_name
    short_name
    disabled
    state
    email
    last_scraper_run_log
    morph_name
    website_url
    population_2017
    scraper_authority_label
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    applications
    comments
    github_issue
    full_name
    short_name
    disabled
    state
    email
    last_scraper_run_log
    morph_name
    website_url
    population_2017
    scraper_authority_label
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

  # Overwrite this method to customize how authorities are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(authority)
  #   "Authority ##{authority.id}"
  # end
end
