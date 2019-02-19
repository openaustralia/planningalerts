# TODO: Store this in a more sensibly named/namespaced variable
ElasticSearchClient = nil

if ENV["ELASTICSEARCH_HOST"].present?
  ElasticSearchClient = Elasticsearch::Client.new hosts: [
    {
      host: ENV["ELASTICSEARCH_HOST"],
      port: ENV["ELASTICSEARCH_PORT"],
      user: ENV["ELASTICSEARCH_USER"],
      password: ENV["ELASTICSEARCH_PASSWORD"],
      scheme: ENV["ELASTICSEARCH_SCHEME"]
    }
  ]
end
