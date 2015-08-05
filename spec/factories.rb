FactoryGirl.define do
  factory :authority do
    sequence(:full_name) { |n| "Acme Local Planning Authority - #{n}" }
    short_name {|b| b.full_name}
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
  end

  factory :user do
    email "foo@bar.com"
    password "foofoo"
  end

  factory :alert do
  end
end
