# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.

# Using marshal (rather than json) so that the flash will store
# whether the string is html_safe 
Rails.application.config.action_dispatch.cookies_serializer = :marshal
