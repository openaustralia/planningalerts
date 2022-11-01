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
    association :authority
    council_reference { "001" }

    factory :application do
      transient do
        address { "A test address" }
        description { "pretty" }
        info_url { "http://foo.com" }
        date_received { nil }
        on_notice_from { nil }
        on_notice_to { nil }
        date_scraped { 10.minutes.ago }
        lat { nil }
        lng { nil }
        suburb { nil }
        state { nil }
        postcode { nil }
      end

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
          date_scraped: evaluator.date_scraped,
          lat: evaluator.lat,
          lng: evaluator.lng,
          suburb: evaluator.suburb,
          state: evaluator.state,
          postcode: evaluator.postcode,
          application: application
        )
      end

      factory :geocoded_application do
        transient do
          lat { 1.0 }
          lng { 2.0 }
          suburb { "Sydney" }
          state { "NSW" }
          postcode { "2000" }
        end
      end
    end
  end

  factory :application_version do
    association :application, factory: :application_with_no_version
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
    association :redirect_application, factory: :application_with_no_version
  end

  factory :add_comment do
    email { "matthew@openaustralia.org" }
    name { "Matthew Landauer" }
    text { "a comment" }
    address { "12 Foo Street" }
  end

  factory :comment do
    user
    name { "Matthew Landauer" }
    text { "a comment" }
    address { "12 Foo Street" }
    association :application, factory: :geocoded_application

    trait :confirmed do
      confirmed { true }
      confirmed_at { 5.minutes.ago }
    end

    factory :unconfirmed_comment do
      confirmed { false }
    end

    factory :confirmed_comment do
      confirmed { true }
      confirmed_at { 5.minutes.ago }
    end
  end

  factory :report do
    name { "Joe Reporter" }
    email { "reporter@foo.com" }
    details { "It's very rude!" }
    comment { :comment }
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
    radius_meters { 2000 }

    factory :unconfirmed_alert do
      confirmed { false }
    end

    factory :confirmed_alert do
      confirmed { true }
      confirm_id { "1234" }

      factory :unsubscribed_alert do
        unsubscribed { true }
        unsubscribed_at { Time.zone.now }
      end
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
end
