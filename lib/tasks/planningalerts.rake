namespace :planningalerts do
  namespace :authorities do
    desc "Load all the authorities data from the scraper web service index"
    task :load => :environment do
      Authority.load_from_web_service(Logger.new(STDOUT))
    end
  end
  
  namespace :applications do
    desc "Scrape all the applications for the last few days for all the loaded authorities"
    task :scrape => :environment do
      Application.collect_applications(Logger.new(STDOUT))
    end
    
    desc "Send planning alerts"
    task :email => :environment do
      Alert.send_alerts(Logger.new(STDOUT))
    end
  end
  
  desc "Generate XML sitemap and notify Google, Yahoo, etc.."
  task :sitemap => :environment do
    s = PlanningAlertsSitemap.new
    s.generate_and_notify
  end
end
