# typed: true
# TODO: Store this in a more sensibly named/namespaced variable

ENV["ELASTICSEARCH_URL"] = Rails.configuration.x.elasticsearch_url
ElasticSearchClient = if Rails.configuration.x.elasticsearch_url.present?
                        Elasticsearch::Client.new url: Rails.configuration.x.elasticsearch_url
                      end
