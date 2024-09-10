# typed: strict
# frozen_string_literal: true

require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  extend T::Sig

  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = T.let({
    id: Field::Number,
    activated_at: Field::DateTime,
    admin: YesNoBooleanField,
    alerts: Field::HasMany,
    api_keys: Field::HasMany,
    comments: Field::HasMany,
    confirmation_sent_at: Field::DateTime,
    confirmation_token: Field::String,
    confirmed_at: Field::DateTime,
    current_sign_in_at: Field::DateTime,
    current_sign_in_ip: Field::String,
    email: Field::String,
    encrypted_password: Field::String,
    failed_attempts: Field::Number,
    from_alert_or_comment: YesNoBooleanField,
    last_sign_in_at: Field::DateTime,
    last_sign_in_ip: Field::String,
    locked_at: Field::DateTime,
    name: Field::String,
    organisation: Field::String,
    password_salt: Field::String,
    remember_created_at: Field::DateTime,
    remember_token: Field::String,
    reports: Field::HasMany,
    reset_password_sent_at: Field::DateTime,
    reset_password_token: Field::String,
    sign_in_count: Field::Number,
    unconfirmed_email: Field::String,
    unlock_token: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    roles: HasManyRolesField
  }.freeze, T::Hash[Symbol, T.untyped])

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = T.let(%i[
    email
    name
    organisation
    admin
    roles
  ].freeze, T::Array[Symbol])

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = T.let(%i[
    email
    name
    organisation
    admin
    roles
    unconfirmed_email
    alerts
    comments
    reports
    api_keys
    created_at
    updated_at
    current_sign_in_at
    last_sign_in_at
    reset_password_sent_at
    confirmed_at
    confirmation_sent_at
    remember_created_at
    current_sign_in_ip
    last_sign_in_ip
    sign_in_count
    activated_at
    from_alert_or_comment
    locked_at
  ].freeze, T::Array[Symbol])

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = T.let(%i[
    name
    organisation
    admin
    roles
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

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.

  sig { params(user: User).returns(String) }
  def display_resource(user)
    user.name_with_fallback
  end
end
