# typed: false
# frozen_string_literal: true

ActiveAdmin.register_page "API usage" do
  content do
    # These URLs require you to login to our Kibana instance with a username and password.
    # So they're relatively safe to include here.
    para do
      link_to "View dashboard in Kibana", "https://d2ba5a791b81410f8d2365c8a6d59905.ap-southeast-2.aws.found.io:9243/app/kibana#/dashboard/8e1285f0-3582-11e9-8f74-c54feae3d9a2?_g=(refreshInterval%3A(pause%3A!t%2Cvalue%3A0)%2Ctime%3A(from%3Anow-1y%2Cmode%3Aquick%2Cto%3Anow))"
    end
    iframe src: "https://d2ba5a791b81410f8d2365c8a6d59905.ap-southeast-2.aws.found.io:9243/app/kibana#/dashboard/8e1285f0-3582-11e9-8f74-c54feae3d9a2?embed=true&_g=(refreshInterval%3A(pause%3A!t%2Cvalue%3A0)%2Ctime%3A(from%3Anow-7d%2Cmode%3Aquick%2Cto%3Anow))", height: "600", width: "100%"
  end
end
