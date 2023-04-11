# typed: true
# TODO: Store this in a more sensibly named/namespaced variable

ElasticSearchClient = if Rails.configuration.x.elasticsearch_url.present?
                        Elasticsearch::Client.new url: Rails.configuration.x.elasticsearch_url
                      end
