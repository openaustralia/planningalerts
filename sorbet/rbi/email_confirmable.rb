# typed: true
# frozen_string_literal: true

# This is a horrible hack
module EmailConfirmable
  def self.scope(*args, &block); end

  def self.where(*args); end

  def self.after_commit(*args, &block); end

  def self.before_create(*args, &block); end

  def self.validates_email_format_of(*attr_names); end

  def self.validates(*attributes); end

  def confirm_id=(value); end
end
