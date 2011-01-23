module Admin

  module PublicHelper

    ##
    # Quick edit usage:
    #
    #     <%= quick_edit(:message => "Edit this article", :path => "articles/edit/#{@article.id}") %>
    #
    # If user is logged in Typus, a link will appear on the top/right of 
    # the pages where you insert this helper.
    #
    def quick_edit(*args)
      render "admin/helpers/quick_edit", :options => args.extract_options!
    end

  end

end