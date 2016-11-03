FactoryGirl.define do
  factory :authority do
    sequence(:full_name) { |n| "Acme Local Planning Authority - #{n}" }
    short_name {|b| b.full_name}
    state "NSW"

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

  factory :add_comment do
    email "matthew@openaustralia.org"
    name "Matthew Landauer"
    text "a comment"
    address "12 Foo Street"
    theme "default"
  end

  factory :comment do
    email "matthew@openaustralia.org"
    name "Matthew Landauer"
    text "a comment"
    address "12 Foo Street"
    association :application

    trait :confirmed do
      confirmed true
      confirmed_at 5.minutes.ago
    end

    factory :unconfirmed_comment do
      confirmed false
    end

    factory :confirmed_comment do
      confirmed true
      confirmed_at 5.minutes.ago
    end

    factory :comment_to_authority do
      councillor_id nil
    end

    factory :comment_to_councillor do
      address nil
      association :councillor
    end
  end

  factory :report do
    name "Joe Reporter"
    email "reporter@foo.com"
    details "It's very rude!"
    comment :comment
  end

  factory :reply do
    text "Thanks for your comment, I agree"
    received_at 1.day.ago
    association :comment
    association :councillor
  end

  factory :councillor do
    name "Louise Councillor"
    email "louise@council.state.gov"
    association :authority
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

    factory :unconfirmed_alert do
      confirmed false
    end

    factory :confirmed_alert do
      confirmed true
      confirm_id "1234"

      factory :unsubscribed_alert do
        unsubscribed true
        unsubscribed_at Time.now
      end
    end
  end

  factory :subscription do
    sequence(:email) { |s| "mary#{s}@enterpriserealty.com.au" }
    stripe_plan_id "planningalerts-34"
  end
end
