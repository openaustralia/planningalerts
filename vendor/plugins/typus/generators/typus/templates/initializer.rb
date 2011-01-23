# Be sure to restart your server when you modify this file.

# System wide options

Typus::Configuration.options[:app_name] = '<%= options[:app_name] %>'
# Typus::Configuration.options[:email] = 'admin@example.com'
# Typus::Configuration.options[:file_preview] = :typus_preview
# Typus::Configuration.options[:file_thumbnail] = :typus_thumbnail
# Typus::Configuration.options[:relationship] = 'typus_users'
# Typus::Configuration.options[:root] = 'admin'
Typus::Configuration.options[:user_class_name] = '<%= options[:user_class_name] %>'
Typus::Configuration.options[:user_fk] = '<%= options[:user_fk] %>'

# Model options which can also be defined by model on the yaml files.

# Typus::Configuration.options[:default_action_on_item] = 'edit'
# Typus::Configuration.options[:end_year] = Time.now.year + 1
# Typus::Configuration.options[:form_rows] = 15
# Typus::Configuration.options[:index_after_save] = true
# Typus::Configuration.options[:minute_step] = 5
# Typus::Configuration.options[:nil] = 'nil'
# Typus::Configuration.options[:on_header] = false
# Typus::Configuration.options[:only_user_items] = false
# Typus::Configuration.options[:per_page] = 15
# Typus::Configuration.options[:sidebar_selector] = 5
# Typus::Configuration.options[:start_year] = Time.now.year - 10
