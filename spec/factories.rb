# frozen_string_literal: true

def create_application(params = {})
  create_application_with_defaults(
    params,
    council_reference: "001",
    date_scraped: 10.minutes.ago,
    address: "A test address",
    description: "pretty",
    info_url: "http://foo.com"
  )
end

def create_geocoded_application(params = {})
  create_application_with_defaults(
    params,
    council_reference: "001",
    date_scraped: 10.minutes.ago,
    address: "A test address",
    description: "pretty",
    info_url: "http://foo.com",
    lat: 1.0,
    lng: 2.0,
    suburb: "Sydney",
    state: "NSW",
    postcode: "2000"
  )
end

def create_application_with_defaults(params, attributes_default)
  valid_keys = %i[
    council_reference lat lng address suburb state postcode date_scraped
    no_alerted authority id description comment_url
  ]
  params.each do |k, _v|
    raise "Invalid key: #{k}" unless valid_keys.include?(k)
  end

  # For simplicity only allow authority to be set by passing authority in params
  raise if params[:authority_id]

  attributes = params.reject do |k, _v|
    %i[authority_id authority council_reference].include?(k)
  end
  CreateOrUpdateApplicationService.call(
    authority: params[:authority] || create(:authority),
    council_reference: params[:council_reference] || attributes_default[:council_reference],
    attributes: attributes_default.merge(attributes)
  )
end

FactoryBot.define do
  factory :authority do
    sequence(:full_name) { |n| "Acme Local Planning Authority - #{n}" }
    short_name(&:full_name)
    state { "NSW" }

    factory :contactable_authority do
      email { "example@authority.gov" }
    end
  end

  # Note that this doesn't have an associated version record with it
  # If you need that you should use create_application or
  # create_geocoded_application above
  factory :application do
    association :authority
    council_reference { "001" }

    factory :application_with_version do
      after(:create) do |application, _evaluator|
        create(
          :geocoded_application_version,
          current: true,
          application: application
        )
      end
    end
  end

  factory :application_version do
    association :application, factory: :application
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
    association :redirect_application, factory: :application
  end

  factory :add_comment do
    email { "matthew@openaustralia.org" }
    name { "Matthew Landauer" }
    text { "a comment" }
    address { "12 Foo Street" }
  end

  factory :comment do
    email { "matthew@openaustralia.org" }
    name { "Matthew Landauer" }
    text { "a comment" }
    address { "12 Foo Street" }
    association :application, factory: :application_with_version

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

    factory :comment_to_authority do
      councillor_id { nil }
    end

    factory :comment_to_councillor do
      address { nil }
      association :councillor
    end
  end

  factory :report do
    name { "Joe Reporter" }
    email { "reporter@foo.com" }
    details { "It's very rude!" }
    comment { :comment }
  end

  factory :reply do
    text { "Thanks for your comment, I agree" }
    received_at { 1.day.ago }
    association :comment
    association :councillor
  end

  factory :councillor do
    name { "Louise Councillor" }
    email { "louise@council.state.gov" }
    association :authority
  end

  factory :user do
    email { "foo@bar.com" }
    password { "foofoo" }

    factory :admin do
      admin { true }
      confirmed_at { 1.day.ago }
    end
  end

  factory :alert do
    email { "mary@example.org" }
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

  factory :suggested_councillor do
    name { "Mila Gilic" }
    email { "mgilic@casey.vic.gov.au" }
    councillor_contribution
  end

  factory :councillor_contribution do
    association :contributor
    association :authority
  end

  factory :contributor do
    name { "Felix Chaung" }
    email { "felix@gmail.com" }
  end
end
