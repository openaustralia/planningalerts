# frozen_string_literal: true

# Hack to work around conflict between kaminari (used by active_admin) and will_paginate (used by the main app)

if defined?(WillPaginate)
  module WillPaginate
    module ActiveRecord
      module RelationMethods
        def per(value = nil)
          per_page(value)
        end

        def total_count()
          count
        end
      end
    end
    module CollectionMethods
      alias_method :num_pages, :total_pages
    end
  end
end
