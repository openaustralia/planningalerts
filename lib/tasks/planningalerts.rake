namespace :planningalerts do
  namespace :authorities do
    desc "Load all the authorities data from the scraper web service index"
    task :load => :environment do
      Authority.load_from_web_service(Logger.new(STDOUT))
    end
  end
  
  namespace :applications do
    desc "Scrape new applications, send emails and generate XML sitemap"
    task :scrape_and_email => [:scrape, :email, :sitemap]
    
    desc "Scrape all the applications for the last few days for all the loaded authorities"
    task :scrape, :authority_short_name, :needs => :environment do |t, args|
      authorities = args[:authority_short_name] ? [Authority.find_by_short_name_encoded(args[:authority_short_name])] : Authority.active
      Application.collect_applications(authorities, Logger.new(STDOUT))
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
