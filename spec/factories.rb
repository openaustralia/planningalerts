FactoryGirl.define do
  factory :authority do
    sequence(:full_name) { |n| "Acme Local Planning Authority - #{n}" }
    short_name {|b| b.full_name}

    factory :contactable_authority do
      email "example@authority.gov"
    end
  end

  factory :application do
    association :authority
    council_reference "001"
    date_scraped {|b| 10.minutes.ago}
    address "A test address"
    description "pretty"
    info_url "http://foo.com"
  end

  factory :comment do
    email "matthew@openaustralia.org"
    name "Matthew Landauer"
    text "a comment"
    address "12 Foo Street"
    association :application

    factory :unconfirmed_comment do
      confirmed false
    end

    factory :confirmed_comment do
      confirmed true
    end

    factory :comment_to_councillor do
      association :councillor
    end
  end

  factory :councillor do
    name "Louise Councillor"
    email "louise@council.state.gov"
  end

  factory :user do
    email "foo@bar.com"
    password "foofoo"

    factory :admin do
      admin true
      confirmed_at 1.days.ago
    end
  end

  factory :alert do
    email "mary@example.org"
    sequence(:address) { |s| "#{s} Illawarra Road Marrickville 2204" }
    lat -33.911105
    lng 151.155503
    radius_meters 2000
  end

  factory :subscription do
    sequence(:email) { |s| "mary#{s}@enterpriserealty.com.au" }
    stripe_plan_id "planningalerts-34"
  end
end
