metric "Email Alerts Signup" do
  description "Measures how many people signup for email alerts and confirmed"
  model Alert, :conditions => { :confirmed => true }
end