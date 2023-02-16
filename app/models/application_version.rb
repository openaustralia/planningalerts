# typed: strict
# frozen_string_literal: true

class ApplicationVersion < ApplicationRecord
  extend T::Sig

  belongs_to :application
  belongs_to :previous_version, class_name: "ApplicationVersion", optional: true

  validates :current, uniqueness: { scope: :application_id }, if: :current

  delegate :authority, :council_reference, to: :application

  sig { returns(T::Hash[String, T.untyped]) }
  def data_attributes
    attributes.except(
      "id", "created_at", "updated_at", "application_id",
      "previous_version_id", "current"
    )
  end

  sig { returns(T::Hash[String, T.untyped]) }
  def changed_data_attributes
    v = previous_version
    if v
      changed = {}
      data_attributes.each_key do |a|
        changed[a] = data_attributes[a] unless data_attributes[a] == v.data_attributes[a]
      end
      changed
    else
      # If this is the first version it's all changed!
      data_attributes
    end
  end

  sig do
    params(
      application_id: Integer,
      previous_version: T.nilable(ApplicationVersion),
      attributes: T::Hash[String, T.untyped]
    ).returns(ApplicationVersion)
  end
  def self.build_version(application_id:, previous_version:, attributes:)
    new(
      (previous_version&.data_attributes || {})
        .merge(attributes)
        .merge(
          "application_id" => application_id,
          "previous_version_id" => previous_version&.id,
          "current" => true
        )
    )
  end
end
