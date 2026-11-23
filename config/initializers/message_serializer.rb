# Be sure to restart your server when you modify this file.

# Sign and encrypt messages as JSON, but still read messages written as Marshal.
# This is the Rails 7.1 default (`:json_allow_marshal`). It lives here, not in
# new_framework_defaults_7_1.rb, because that file is deleted once we set
# `config.load_defaults 7.1`, and this setting must outlast it.
#
# The only signed links we know of are the Active Storage attachment links in
# support emails to staff, and emails sent before this change carry Marshal ones.
# Keep reading both formats for at least 120 days after this reached production,
# then change this to `:json` (the Rails 7.2 default) or delete this file.
# Marshal is only read after the signature checks out, so the risk is limited to
# a leaked `secret_key_base`.
# See https://github.com/openaustralia/oaf-internal/issues/372
Rails.application.config.active_support.message_serializer = :json_allow_marshal
