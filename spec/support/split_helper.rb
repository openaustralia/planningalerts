module SplitHelper
  # Force a specific experiment alternative to always be returned:
  #   use_ab_test(signup_form: "single_page")
  #
  # Force alternatives for multiple experiments:
  #   use_ab_test(signup_form: "single_page", pricing: "show_enterprise_prices")
  #
  def use_ab_test(alternatives_by_experiment)
    allow_any_instance_of(Split::Helper).to receive(:ab_test) do |_receiver, experiment, &block|
      variant = alternatives_by_experiment.fetch(experiment) { |key| raise "Unknown experiment '#{key}'" }
      block.call(variant) unless block.nil?
      variant
    end
  end
end

# Make the `use_ab_test` method available to all specs:
RSpec.configure do |config|
  config.include SplitHelper
end
