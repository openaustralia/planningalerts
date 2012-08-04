ab_test "Remove RSS on application detail page" do
  description "Testing to see if removing the RSS feed choice makes someone more likely to sign up to an email alert"
  metrics :alert_signup
end