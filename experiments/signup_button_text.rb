ab_test "Singup button text" do
  description "What effect will changing the signup button text have on the application detail page?"
  alternatives "Alert Me", "Sign Me Up", "Create Alert", "Email Me"
  metrics :alert_signup
end