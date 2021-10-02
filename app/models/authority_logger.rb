# typed: false
# frozen_string_literal: true

class AuthorityLogger < Logger
  extend T::Sig

  sig { params(authority_id: Integer, other_logger: Logger).void }
  def initialize(authority_id, other_logger)
    @authority_id = authority_id
    @other_logger = other_logger
    # We're starting a new run of the logger & scraper so clear out the old so we're ready for the new
    Authority.update(@authority_id, last_scraper_run_log: "")
  end

  sig { params(severity: Integer, message: T.nilable(String), progname: T.nilable(String)).void }
  def add(severity, message = nil, progname = nil)
    # Using block form of Logger#add because sorbet thinks the block is required (which it isn't)
    # By always using the block form we end up with output like "message: nil" which is ugly
    # and confusing.
    # TODO: Don't use block form as soon as possible
    @other_logger.add(severity, nil, progname) { message }
    # Put a maximum limit on how long the log can get
    e = (Authority.find(@authority_id).last_scraper_run_log || "") + (progname || "") + "\n"
    return if e.size >= 5000

    # We want this log to be written even if the rest of the authority
    # object doesn't validate
    Authority.update(@authority_id, last_scraper_run_log: e)
  end
end
