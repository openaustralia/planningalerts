# typed: strict
# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn,
  # Personal information (Australian Privacy Principles): email addresses
  # anywhere, and the address a person watches with an alert, which is
  # effectively their home address. Addresses of planning applications are
  # public record and are deliberately not filtered.
  :email, "alert.address"
]
