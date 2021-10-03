# typed: true
# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.

# TODO: Switch over to :json after we've been on :hybrid for a month or so at least
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
