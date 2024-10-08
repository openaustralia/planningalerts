# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `ProcessAlertJob`.
# Please instead update this file by running `bin/tapioca dsl ProcessAlertJob`.


class ProcessAlertJob
  class << self
    sig { params(id: ::Integer).returns(String) }
    def perform_async(id); end

    sig { params(interval: T.any(DateTime, Time), id: ::Integer).returns(String) }
    def perform_at(interval, id); end

    sig { params(interval: Numeric, id: ::Integer).returns(String) }
    def perform_in(interval, id); end
  end
end
