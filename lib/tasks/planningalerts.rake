# frozen_string_literal: true

# Shared reporting for the planningalerts:bulk_*_applications tasks
def print_bulk_moderation_report(result, authority:, prefix:, rerun_command:)
  dry_run = result.dry_run
  delete = result.mode == BulkModerateApplicationsService::Mode::Delete
  verb = case result.mode
         when BulkModerateApplicationsService::Mode::Delete then "delete"
         when BulkModerateApplicationsService::Mode::Hide then "hide"
         when BulkModerateApplicationsService::Mode::Unhide then "unhide"
         end
  past = { "delete" => "Deleted", "hide" => "Hid", "unhide" => "Unhid" }.fetch(verb)

  describe = ->(item) { "  #{item.council_reference} (id #{item.id}) - #{item.address}" }
  comments = lambda do |item|
    if item.comments_count.zero?
      ""
    elsif delete
      " - including #{item.comments_count} comment(s)"
    else
      " - has #{item.comments_count} comment(s)"
    end
  end

  puts "#{'DRY RUN - nothing was changed - ' if dry_run}#{authority.full_name} - " \
       "applications with council_reference starting with #{prefix.inspect}"
  puts

  puts "#{dry_run ? "Would #{verb}" : past} #{result.changed.count} application(s):"
  result.changed.each { |item| puts describe.call(item) + comments.call(item) }

  if result.skipped_comments.any?
    puts
    puts "Skipped #{result.skipped_comments.count} application(s) because they have comments " \
         "(pass delete_comments to delete them too):"
    result.skipped_comments.each { |item| puts describe.call(item) + " - #{item.comments_count} comment(s)" }
  end

  if result.skipped_redirect_target.any?
    puts
    puts "Skipped #{result.skipped_redirect_target.count} application(s) because they are the target " \
         "of an application redirect. These need to be handled manually:"
    result.skipped_redirect_target.each { |item| puts describe.call(item) }
  end

  if result.skipped_unchanged.any?
    puts
    reason = if result.mode == BulkModerateApplicationsService::Mode::Hide
               "they are already hidden (their existing hidden reason is kept)"
             else
               "they are not hidden"
             end
    puts "Skipped #{result.skipped_unchanged.count} application(s) because #{reason}:"
    result.skipped_unchanged.each { |item| puts describe.call(item) }
  end

  return unless dry_run

  puts
  puts "This was a dry run. To actually #{verb} run the task again with execute, e.g."
  puts "  #{rerun_command}"
end

namespace :planningalerts do
  # Updates:
  # * state
  # * population
  # * website_url
  # * asgs (ABS code for LGA)
  desc "Update authorities from wikidata"
  task update_authorities_from_wikidata: :environment do
    data = WikidataService.all_data
    Authority.active.find_each do |authority|
      if authority.wikidata_id.blank?
        puts "Skipping #{authority.full_name} because wikidata_id is blank"
        next
      end

      row = data[authority.wikidata_id]
      raise "wikidata_id for #{authority.full_name} does not point to an LGA" if row.nil?

      puts "#{authority.full_name} - state: #{authority.state} => #{row[:state]}" if row[:state] != authority.state
      puts "#{authority.full_name} - population_2021: #{authority.population_2021} => #{row[:population_2021]}" if row[:population_2021] != authority.population_2021
      puts "#{authority.full_name} - website_url: #{authority.website_url} => #{row[:website_url]}" if row[:website_url] != authority.website_url
      puts "#{authority.full_name} - asgs_2021: #{authority.asgs_2021} => #{row[:asgs_2021]}" if row[:asgs_2021] != authority.asgs_2021
      authority.update!(
        state: row[:state],
        population_2021: row[:population_2021],
        website_url: row[:website_url],
        asgs_2021: row[:asgs_2021]
      )
    end
  end

  desc "Read shapefile"
  task read_shapefile: :environment do
    require "zip"

    unless File.exist?("tmp/boundaries/LGA_2022_AUST_GDA94.shp")
      puts "Downloading shapefile..."
      FileUtils.mkdir_p("tmp/boundaries")
      URI.open("https://www.abs.gov.au/statistics/standards/australian-statistical-geography-standard-asgs-edition-3/jul2021-jun2026/access-and-downloads/digital-boundary-files/LGA_2022_AUST_GDA94_SHP.zip") do |f|
        zip_stream = Zip::InputStream.new(f)
        while (entry = zip_stream.get_next_entry)
          # Extract into tmp/boundaries directory
          entry.extract("tmp/boundaries/#{entry.name}")
        end
      end
    end

    # See http://www.geoproject.com.au/gda.faq.html
    # "What is the difference between GDA94 and WGS84?"
    # Difference between GDA94 and WGS84 is going to be of the order of a metre
    # or so so we can probably just ignore the difference for the time being
    # TODO: #2164 Properly support the conversion

    # We're just loading the GDA94 as if it's WGS84 (srid 4326)
    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    RGeo::Shapefile::Reader.open("tmp/boundaries/LGA_2022_AUST_GDA94.shp", factory:) do |file|
      file.each do |record|
        # First get the LGA code for the current record
        asgs_2021 = "LGA#{record.attributes['LGA_CODE22']}"
        # Lookup the associated authority
        authority = Authority.find_by(asgs_2021:)
        # We expect there to be more authorities included in the shapefile
        # then we have in PlanningAlerts currently. So, just silently ignore
        # if we can't find it.
        next if authority.nil?

        puts "Loading boundary for #{authority.full_name}..."
        authority.update!(boundary: record.geometry)
      end
    end
  end

  # Dry run by default. Pass "execute" as the third argument to actually
  # delete and "delete_comments" as the fourth argument to also delete any
  # comments on matching applications (otherwise applications with comments
  # are skipped). For example:
  #   rake planningalerts:bulk_delete_applications[123,PA1]                          # dry run
  #   rake planningalerts:bulk_delete_applications[123,PA1,execute]                  # delete
  #   rake planningalerts:bulk_delete_applications[123,PA1,execute,delete_comments]  # delete incl. comments
  desc "Bulk delete applications for an authority matching a council_reference prefix (dry run by default)"
  task :bulk_delete_applications, %i[authority_id prefix mode option] => :environment do |_task, args|
    authority = Authority.find(args.authority_id)
    prefix = args.prefix.to_s
    raise "prefix can't be blank" if prefix.blank?
    raise "Unknown mode: #{args.mode}. Did you mean execute?" unless args.mode.nil? || args.mode == "execute"
    raise "Unknown option: #{args.option}. Did you mean delete_comments?" unless args.option.nil? || args.option == "delete_comments"

    dry_run = args.mode != "execute"
    delete_comments = args.option == "delete_comments"

    result = BulkModerateApplicationsService.call(
      authority:,
      council_reference_prefix: prefix,
      mode: BulkModerateApplicationsService::Mode::Delete,
      dry_run:,
      delete_comments:
    )

    print_bulk_moderation_report(
      result,
      authority:,
      prefix:,
      rerun_command: "rake planningalerts:bulk_delete_applications[#{authority.id},#{prefix},execute]"
    )
  end

  # Dry run by default. Pass "execute" as the third argument to actually hide.
  # The hidden reason is required and is passed via the REASON environment
  # variable so it can contain spaces and commas. It is published word-for-word
  # on the public page for each hidden application. Unlike deleting, hiding is
  # safe for applications with comments and applications that are the target of
  # an application redirect, so nothing is skipped except applications that are
  # already hidden (their existing hidden reason is kept). For example:
  #   REASON="Duplicate record" rake planningalerts:bulk_hide_applications[123,PA1]          # dry run
  #   REASON="Duplicate record" rake planningalerts:bulk_hide_applications[123,PA1,execute]  # hide
  desc "Bulk hide applications for an authority matching a council_reference prefix (dry run by default)"
  task :bulk_hide_applications, %i[authority_id prefix mode] => :environment do |_task, args|
    authority = Authority.find(args.authority_id)
    prefix = args.prefix.to_s
    reason = ENV.fetch("REASON", nil)
    raise "prefix can't be blank" if prefix.blank?
    raise "Unknown mode: #{args.mode}. Did you mean execute?" unless args.mode.nil? || args.mode == "execute"

    if reason.blank?
      raise "REASON can't be blank. It is published word-for-word on the public page for each " \
            "hidden application, e.g. REASON=\"Duplicate record\" rake planningalerts:bulk_hide_applications[...]"
    end

    dry_run = args.mode != "execute"

    result = BulkModerateApplicationsService.call(
      authority:,
      council_reference_prefix: prefix,
      mode: BulkModerateApplicationsService::Mode::Hide,
      dry_run:,
      hidden_reason: reason
    )

    print_bulk_moderation_report(
      result,
      authority:,
      prefix:,
      rerun_command: "REASON=#{reason.inspect} rake planningalerts:bulk_hide_applications[#{authority.id},#{prefix},execute]"
    )
  end

  # Dry run by default. Pass "execute" as the third argument to actually
  # unhide. Unhiding also clears the hidden reason on each application.
  # Applications that are not hidden are skipped. For example:
  #   rake planningalerts:bulk_unhide_applications[123,PA1]          # dry run
  #   rake planningalerts:bulk_unhide_applications[123,PA1,execute]  # unhide
  desc "Bulk unhide applications for an authority matching a council_reference prefix (dry run by default)"
  task :bulk_unhide_applications, %i[authority_id prefix mode] => :environment do |_task, args|
    authority = Authority.find(args.authority_id)
    prefix = args.prefix.to_s
    raise "prefix can't be blank" if prefix.blank?
    raise "Unknown mode: #{args.mode}. Did you mean execute?" unless args.mode.nil? || args.mode == "execute"

    dry_run = args.mode != "execute"

    result = BulkModerateApplicationsService.call(
      authority:,
      council_reference_prefix: prefix,
      mode: BulkModerateApplicationsService::Mode::Unhide,
      dry_run:
    )

    print_bulk_moderation_report(
      result,
      authority:,
      prefix:,
      rerun_command: "rake planningalerts:bulk_unhide_applications[#{authority.id},#{prefix},execute]"
    )
  end

  namespace :emergency do
    desc "Regenerates all the counter caches in case they got out of synch"
    task fixup_counter_caches: :environment do
      Comment.counter_culture_fix_counts
    end
  end

  namespace :migrate do
    desc "Update lonlat on applications, application_versions and alerts"
    task update_lonlat: :environment do
      ActiveRecord::Base.connection.execute("UPDATE applications SET lonlat = ST_POINT(lng, lat) WHERE lonlat IS NULL")
      ActiveRecord::Base.connection.execute("UPDATE application_versions SET lonlat = ST_POINT(lng, lat) WHERE lonlat IS NULL")
      ActiveRecord::Base.connection.execute("UPDATE alerts SET lonlat = ST_POINT(lng, lat) WHERE lonlat IS NULL")
    end
  end

  namespace :development do
    desc "Send example test email alert to given email address"
    task :test_alert, [:email] => :environment do |_task, args|
      alert = Alert.new(
        lat: -33.902723,
        lng: 151.163362,
        radius_meters: 200,
        user: User.new(email: args.email.inspect, password: "foo"),
        address: "89 Bridge Rd, Richmond VIC 3121",
        confirm_id: "1234",
        id: 1
      )
      application1 = Application.new(
        id: 1,
        address: "6 Kahibah Road, Umina Beach, NSW",
        lat: -33.90413,
        lng: 151.16163,
        description: "S4.55 to Modify Approved Dwelling and Garage including Deletion of Clerestory, Addition of Laminated Beam, " \
                     "Relocation of Laundry, Deletion of Stairs and Expansion of Workshop"
      )
      application2 = Application.new(
        id: 2,
        address: "6 Kahibah Road, Umina Beach, NSW",
        lat: -33.90413,
        lng: 151.16163,
        description: "Building subdivision"
      )
      comment = Comment.new(
        application: Application.new(
          id: 2,
          address: "6 Kahibah Road, Umina Beach, NSW",
          lat: -33.90413,
          lng: 151.16163,
          description: "S4.55 to Modify Approved Dwelling and Garage including Deletion of Clerestory, Addition of Laminated Beam, " \
                       "Relocation of Laundry, Deletion of Stairs and Expansion of Workshop"
        ),
        text: "It has recently come to my attention that a planning application has been submitted" \
              "for 813 Hight Street, Reservoir.\n\n" \
              "My concern is with the application for ground floor shops and nine (9) dwellings," \
              "above, with a reduction in the car parking requirements.\n\n" \
              "Currently, there are already parking issues in the area, with insufficient parking" \
              "bays available. Residents of Wild Street and Henry Street are constantly complaining" \
              "about cars parked on \"their\" street. We often find abusive notes left on vehicles," \
              "harassment of staff when in the street, and stupid acts of vandalism. We are a" \
              "business on High Street and staff already have difficulty finding parking as it" \
              "is. It appears that the council is not concerned for its local businesses or residents" \
              "and allowing a new building with reduced parking is irresponsible and inconsiderate." \
              "I understand that the council and developers want to make as much money as possible but" \
              "it is extremely unfair to cause such distress and inconvenience to everyone else." \
              "I strongly oppose such a development and would like further information as to how to" \
              "make this a formal objection.\n\n" \
              "Regards\n" \
              "Louise",
        name: "Martha"
      )

      AlertMailer.alert(alert:, applications: [application1, application2], comments: [comment]).deliver_now
      puts "Sent example email alert to #{alert.user.email}"
    end
  end
end
