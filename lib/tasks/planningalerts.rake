namespace :planningalerts do
  namespace :authorities do
    desc "Load all the authorities data from the scraper web service index"
    task :load => :environment do
      # Log to standard out
      Authority.logger = Logger.new(STDOUT)
      Authority.load_from_web_service
    end
  end
end
