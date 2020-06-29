# typed: true
# TODO: Store this in a more sensibly named/namespaced variable

ElasticSearchClient = if ENV["ELASTICSEARCH_URL"].present?
                        Elasticsearch::Client.new url: ENV["ELASTICSEARCH_URL"]
                      end
