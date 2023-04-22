# typed: true
# TODO: Store this in a more sensibly named/namespaced variable

ENV["ELASTICSEARCH_URL"] = Rails.configuration.x.elasticsearch_url
# TODO: With the line above can I get rid of the stuff below?
ElasticSearchClient = if Rails.configuration.x.elasticsearch_url.present?
                        Elasticsearch::Client.new url: Rails.configuration.x.elasticsearch_url
                      end
