# frozen_string_literal: true

FactoryBot.define do
  factory :authority do
    sequence(:full_name) { |n| "Acme Local Planning Authority - #{n}" }
    short_name(&:full_name)
    state { "NSW" }
    disabled { false }

    factory :contactable_authority do
      email { "example@authority.gov" }
    end
  end

  factory :application_with_no_version, class: "Application" do
    authority
    council_reference { "001" }
    date_scraped { 10.minutes.ago }
    address { "A test address" }
    description { "pretty" }
    info_url { "http://foo.com" }

    factory :application do
      date_received { nil }
      on_notice_from { nil }
      on_notice_to { nil }

      after(:create) do |application, evaluator|
        create(
          :application_version,
          current: true,
          address: evaluator.address,
          description: evaluator.description,
          info_url: evaluator.info_url,
          date_received: evaluator.date_received,
          on_notice_from: evaluator.on_notice_from,
          on_notice_to: evaluator.on_notice_to,
          comment_email: evaluator.comment_email,
          comment_authority: evaluator.comment_authority,
          date_scraped: evaluator.date_scraped,
          lat: evaluator.lat,
          lng: evaluator.lng,
          suburb: evaluator.suburb,
          state: evaluator.state,
          postcode: evaluator.postcode,
          application:
        )
        application.update!(
          first_date_scraped: evaluator.date_scraped
        )
      end

      factory :geocoded_application do
        lat { 1.0 }
        lng { 2.0 }
        lonlat { RGeo::Geographic.spherical_factory(srid: 4326).point(2.0, 1.0) }
        suburb { "Sydney" }
        state { "NSW" }
        postcode { "2000" }
      end
    end
  end

  factory :application_version do
    application factory: %i[application_with_no_version]
    date_scraped { |_b| 10.minutes.ago }
    address { "A test address" }
    description { "pretty" }
    info_url { "http://foo.com" }
    current { false }

    factory :geocoded_application_version do
      lat { 1.0 }
      lng { 2.0 }
      suburb { "Sydney" }
      state { "NSW" }
      postcode { "2000" }
    end
  end

  factory :application_redirect do
    application_id { 1 }
    redirect_application factory: %i[application_with_no_version]
  end

  factory :comment do
    user
    name { "Matthew Landauer" }
    text { "a comment" }
    address { "12 Foo Street" }
    application factory: %i[geocoded_application]
    previewed { false }

    trait :confirmed do
      confirmed { true }
      confirmed_at { 5.minutes.ago }
    end

    factory :unconfirmed_comment do
      confirmed { false }
    end

    factory :confirmed_comment do
      confirmed { true }
      previewed { true }
      confirmed_at { 5.minutes.ago }
      published_at { 5.minutes.ago }
    end
  end

  factory :report do
    name { "Joe Reporter" }
    email { "reporter@foo.com" }
    details { "It's very rude!" }
    comment
  end

  factory :user do
    sequence :email do |n|
      "user#{n}@bar.com"
    end
    password { "foofoo" }

    factory :admin do
      admin { true }
      confirmed_at { 1.day.ago }
    end

    factory :confirmed_user do
      confirmed_at { Time.zone.now }
    end
  end

  factory :api_key do
    user
  end

  factory :alert do
    user
    sequence(:address) { |s| "#{s} Illawarra Road Marrickville 2204" }
    lat { -33.911105 }
    lng { 151.155503 }
    lonlat { RGeo::Geographic.spherical_factory(srid: 4326).point(151.155503, -33.911105) }
    radius_meters { 2000 }
    confirmed { true }
    confirm_id { "1234" }

    factory :unsubscribed_alert do
      unsubscribed { true }
      unsubscribed_at { Time.zone.now }
    end
  end

  factory :alert_subscriber do
    email { "eliza@example.org" }
  end

  factory :donation do
    sequence(:email) { |s| "mary#{s}@enterpriserealty.com.au" }
  end

  factory :subscription do
    sequence(:email) { |s| "mary#{s}@enterpriserealty.com.au" }
  end

  factory :contact_message do
    email { "eliza@example.org" }
    reason { "I have a privacy concern" }
    details { "I included my address in my comment by accident. Please remove it." }
  end
end
