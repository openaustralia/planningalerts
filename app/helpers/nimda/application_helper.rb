module Nimda
  module ApplicationHelper
    def add_active_to_search(search_term)
      "active: " + search_term
    end

    def include_active?(search_term)
      search_term.split(" ").include?("active:")
    end
  end
end
