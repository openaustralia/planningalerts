# typed: strict
# frozen_string_literal: true

require "administrate/base_dashboard"

class AnnouncementDashboard < Administrate::BaseDashboard
  extend T::Sig

  ATTRIBUTE_TYPES = T.let({
    id: Field::Number,
    body: Field::Text,
    published: YesNoBooleanField,
    starts_at: UtcDateTimeField,
    ends_at: UtcDateTimeField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    versions: Field::PaperTrail
  }.freeze, T::Hash[Symbol, T.untyped])

  COLLECTION_ATTRIBUTES = T.let(%i[
    id
    body
    published
    starts_at
    ends_at
  ].freeze, T::Array[Symbol])

  SHOW_PAGE_ATTRIBUTES = T.let(%i[
    id
    body
    published
    starts_at
    ends_at
    created_at
    updated_at
    versions
  ].freeze, T::Array[Symbol])

  FORM_ATTRIBUTES = T.let(%i[
    body
    published
    starts_at
    ends_at
  ].freeze, T::Array[Symbol])

  COLLECTION_FILTERS = T.let({}.freeze, T::Hash[Symbol, T.untyped])

  sig { params(announcement: Announcement).returns(String) }
  def display_resource(announcement)
    "Announcement ##{announcement.id}"
  end
end
