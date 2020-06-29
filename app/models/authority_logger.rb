# typed: true
# frozen_string_literal: true

class AuthorityLogger < Logger
  def initialize(authority_id, other_logger)
    @authority_id = authority_id
    @other_logger = other_logger
    # We're starting a new run of the logger & scraper so clear out the old so we're ready for the new
    Authority.update(@authority_id, last_scraper_run_log: "")
  end

  def add(severity, message = nil, progname = nil)
    @other_logger.add(severity, message, progname)
    # Put a maximum limit on how long the log can get
    e = Authority.find(@authority_id).last_scraper_run_log + progname + "\n"
    return if e.size >= 5000

    # We want this log to be written even if the rest of the authority
    # object doesn't validate
    Authority.update(@authority_id, last_scraper_run_log: e)
  end
end
