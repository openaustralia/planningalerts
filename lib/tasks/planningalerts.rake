namespace :planningalerts do
  namespace :authorities do
    desc "Load all the authorities data from the scraper web service index"
    task :load => :environment do
      # Log to standard out
      Authority.logger = Logger.new(STDOUT)
      Authority.load_from_web_service
    end
  end
  
  namespace :application do
    desc "Scrape all the applications for the last few days for all the loaded authorities"
    task :scrape => :environment do
      Application.collect_applications(Logger.new(STDOUT))
    end
  end
end
