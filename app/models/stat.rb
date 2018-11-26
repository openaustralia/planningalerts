# frozen_string_literal: true

class Stat < ApplicationRecord
  def self.applications_sent
    get_value_for_key("applications_sent")
  end

  def self.applications_sent=(value)
    set_value_for_key("applications_sent", value)
  end

  def self.emails_sent
    get_value_for_key("emails_sent")
  end

  def self.emails_sent=(value)
    set_value_for_key("emails_sent", value)
  end

  def self.set_value_for_key(key, value)
    r = record_for_key(key)
    r.value = value
    r.save!
  end

  def self.get_value_for_key(key)
    record_for_key(key).value
  end

  def self.record_for_key(key)
    Stat.find_or_create_by(key: key) { |s| s.value = 0 }
  end
end
