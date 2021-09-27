module Nimda
  module ApplicationHelper
    def add_tag_to_search(tag, search_term)
      tag + ": " + search_term
    end

    def include_search_tag?(tag, search_term)
      search_term.split(" ").include?(tag + ":")
    end
  end
end
