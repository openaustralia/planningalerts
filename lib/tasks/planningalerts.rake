namespace :planningalerts do
  namespace :applications do
    desc "Scrape new applications, index them, send emails and generate XML sitemap"
    task :scrape_and_email => [:scrape, 'ts:index', :email, :sitemap]

    desc "Scrape all the applications for the last few days for all the loaded authorities"
    task :scrape, [:authority_short_name] => :environment do |t, args|
      authorities = args[:authority_short_name] ? [Authority.find_by_short_name_encoded(args[:authority_short_name])] : Authority.active
      Application.collect_applications(authorities, Logger.new(STDOUT))
    end

    desc "Send planning alerts"
    task :email => :environment do
      Alert.process_all_active_alerts(Logger.new(STDOUT))
    end
  end

  desc "Generate XML sitemap"
  task :sitemap => :environment do
    s = PlanningAlertsSitemap.new
    s.generate
  end

  # A response to something bad
  namespace :emergency do
    # TODO: Move comments of destroyed applications to the redirected application
    desc "Applications for an authority shouldn't have duplicate values of council_reference and so this removes duplicates."
    task :fix_duplicate_council_references => :environment do
      # First find all duplicates
      duplicates = Application.group(:authority_id).group(:council_reference).count.select{|k,v| v > 1}.map{|k,v| k}
      duplicates.each do |authority_id, council_reference|
        authority = Authority.find(authority_id)
        puts "Removing duplicates for #{authority.full_name_and_state} - #{council_reference} and redirecting..."
        applications = authority.applications.where(council_reference: council_reference)
        # The first result is the most recently scraped. We want to keep the last result which was the first
        # one scraped
        application_to_keep = applications[-1]
        applications[0..-2].each do |a|
          ActiveRecord::Base.transaction do
            # Set up a redirect from the wrong to the right
            ApplicationRedirect.create!(:application_id => a.id, :redirect_application_id => application_to_keep.id)
            a.destroy
          end
        end
      end
    end
  end

  namespace :subscriptions do
    desc "Creates trial subscriptions for the requested number of random people with 3 or more alerts"
    task :rollout, [:stripe_plan_id, :count] => :environment do |t, args|
      raise "Unknown Stripe plan ID" unless Subscription::PLAN_IDS.include?(args[:stripe_plan_id])

      # The requested number of random alerts...
      # ...where there's 3 or more other active alerts already signed up...
      # ...and they don't already have a subscription...
      # ...pluck just the email addresses
      emails = Alert.potential_new_subscribers.order("RAND()").limit(args[:count]).pluck(:email)

      if emails.empty?
        puts "Sorry, no subscription candidates were found."
      else
        puts emails.join("\n")
        if confirm_question "Create subscriptions for the above addresses?"
          emails.each do |email|
            puts "Creating trial subscription for #{email}..."
            Subscription.create!(email: email, stripe_plan_id: args[:stripe_plan_id], trial_started_at: Date.today)
          end
          puts "Done."
        else
          puts "Cancelled."
        end
      end
    end
  end

  def confirm_question(message)
    STDOUT.puts "#{message} (y/n)"
    STDIN.gets.strip == 'y'
  end
end
