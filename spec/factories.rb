Factory.define :authority do |a|
  a.full_name "Acme Local Planning Authority"
  a.short_name {|b| b.full_name}
end

Factory.define :application do |a|
  a.association :authority
  a.council_reference "001"
  a.date_scraped {|b| 10.minutes.ago}
end