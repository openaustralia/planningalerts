# frozen_string_literal: true

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
    # TODO: Properly support the conversion

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
        user: User.new(email: args.email.inspect, password: "foo", tailwind_theme: true),
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
