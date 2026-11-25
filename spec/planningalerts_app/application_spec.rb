# frozen_string_literal: true

require "spec_helper"

# The Rails 7.1 settings we run with. `config.load_defaults 7.1` in
# config/application.rb sets them, apart from the message serialiser, which we
# set ourselves. This spec was written before the switch to
# load_defaults 7.1 and passed both before and after it, so the switch changed
# none of these. It fails if a setting is lost, such as by lowering load_defaults.
#
# The page, email and request specs check what the settings do. This checks the
# settings themselves are in place. A missing setting counts as a failure, even
# where its default would give the same value.
describe PlanningalertsApp::Application do
  let(:config) { Rails.application.config }

  {
    action_controller: {
      allow_deprecated_parameters_hash_equality: false
    },
    active_job: {
      use_big_decimal_serializer: true
    },
    active_record: {
      allow_deprecated_singular_associations_name: false,
      before_committed_on_all_records: true,
      belongs_to_required_validates_foreign_key: false,
      commit_transaction_on_non_local_return: true,
      default_column_serializer: nil,
      generate_secure_token_on: :initialize,
      marshalling_format_version: 7.1,
      raise_on_assign_to_attr_readonly: true,
      run_after_transaction_callbacks_in_order_defined: true,
      run_commit_callbacks_on_first_saved_instances_in_transaction: false
    },
    action_dispatch: {
      debug_exception_log_level: :error
    },
    active_support: {
      message_serializer: :json_allow_marshal,
      raise_on_invalid_cache_expiration_time: true,
      use_message_serializer_for_metadata: true
    }
  }.each do |framework, settings|
    settings.each do |name, value|
      it "sets #{framework}.#{name} to #{value.inspect}" do
        expect(config.public_send(framework).fetch(name)).to eq value
      end
    end
  end

  it "sets encryption.support_sha1_for_non_deterministic_encryption to false" do
    expect(config.active_record.encryption.fetch(:support_sha1_for_non_deterministic_encryption)).to be false
  end

  # Rails reads these two at boot and removes them from the config, so they are
  # checked where Rails keeps them.
  it "cleans HTML in views with the HTML5 sanitiser" do
    expect(ActionView::Helpers::SanitizeHelper.sanitizer_vendor).to eq Rails::HTML5::Sanitizer
  end

  it "writes cache entries in the 7.1 format" do
    expect(ActiveSupport::Cache.format_version).to eq 7.1
  end

  it "precompiles filter_parameters" do
    expect(config.precompile_filter_parameters).to be true
  end

  it "does not add autoloaded paths to the load path" do
    expect(config.add_autoload_paths_to_load_path).to be false
  end

  it "parses HTML as HTML5 in test helpers" do
    expect(config.dom_testing_default_html_version).to eq :html5
  end

  it "sends Rails' default security headers" do
    expect(config.action_dispatch.default_headers.keys).to contain_exactly(
      "X-Frame-Options", "X-XSS-Protection", "X-Content-Type-Options",
      "X-Permitted-Cross-Domain-Policies", "Referrer-Policy"
    )
  end

  it "limits the size of the log file" do
    expect(config.log_file_size).to eq 100 * 1024 * 1024
  end
end
