# Only used in the ATDIS test harness.
# TODO: Should probably have a better name that is less generic
class Feed
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :base_url, :page, :postcode

  def initialize(options = {})
    @base_url = options[:base_url]
    @page = options[:page] || 1
    @postcode = options[:postcode]
  end

  def persisted?
    false
  end
end