# frozen_string_literal: true

namespace :planningalerts do
  desc "Generate XML sitemap"
  task sitemap: :environment do
    GenerateSitemapService.call
  end

  namespace :emergency do
    desc "Regenerates all the counter caches in case they got out of synch"
    task fixup_counter_caches: :environment do
      Comment.counter_culture_fix_counts
    end
  end

  namespace :migrate do
    desc "copy current version data back to application"
    task copy_current_version_data_back_to_application: :environment do
      applications = Application.where(address: nil)
      puts "#{applications.count} to migrate..."
      progressbar = ProgressBar.create(total: applications.count, format: "%t: |%B| %e")
      applications.includes(:current_version).find_each do |application|
        application.update!(
          address: application.current_version.address,
          description: application.current_version.description,
          info_url: application.current_version.info_url,
          date_received: application.current_version.date_received,
          on_notice_from: application.current_version.on_notice_from,
          on_notice_to: application.current_version.on_notice_to,
          date_scraped: application.current_version.date_scraped,
          lat: application.current_version.lat,
          lng: application.current_version.lng,
          suburb: application.current_version.suburb,
          state: application.current_version.state,
          postcode: application.current_version.postcode,
          comment_email: application.current_version.comment_email,
          comment_authority: application.current_version.comment_authority
        )
        progressbar.increment
      end
    end
  end
end
