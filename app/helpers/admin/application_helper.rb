# typed: strict
# frozen_string_literal: true

module Admin
  module ApplicationHelper
    extend T::Sig

    sig { params(tag: String, search_term: String).returns(String) }
    def add_tag_to_search(tag, search_term)
      "#{tag}: #{search_term}"
    end

    sig { params(tag: String, search_term: String).returns(T::Boolean) }
    def include_search_tag?(tag, search_term)
      search_term.split(" ").include?("#{tag}:")
    end
  end
end
