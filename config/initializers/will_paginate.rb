# Hack to work around conflict between kaminari (used by active_admin) and will_paginate (used by the main app)

if defined?(WillPaginate)
  module WillPaginate
    module ActiveRecord
      module RelationMethods
        alias per per_page
        alias num_pages total_pages
        alias total_count count
      end
    end
  end
end
