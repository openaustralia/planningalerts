# typed: true

# ElasticSearchClient is initialised in config/initializers/elasticsearch.rb,
# which Sorbet excludes. This shim keeps the constant visible to the type
# checker.
ElasticSearchClient = T.let(T.unsafe(nil), T.nilable(Elasticsearch::Client))
