module Admin::MasterHelper

  include TypusHelper

  include Admin::SidebarHelper
  include Admin::FormHelper
  include Admin::TableHelper

  def display_link_to_previous

    options = {}
    options[:resource_from] = @resource[:human_name]
    options[:resource_to] = params[:resource].classify.constantize.human_name if params[:resource]

    editing = %w( edit update ).include?(params[:action])

    message = case
              when params[:resource] && editing
                "You're updating a %{resource_from} for %{resource_to}."
              when editing
                "You're updating a %{resource_from}."
              when params[:resource]
                "You're adding a new %{resource_from} to %{resource_to}."
              else
                "You're adding a new %{resource_from}."
              end

    message = _(message, 
                :resource_from => options[:resource_from], 
                :resource_to => options[:resource_to])

    render "admin/helpers/display_link_to_previous", :message => message

  end

  def remove_filter_link(filter = request.env['QUERY_STRING'])
    return unless filter && !filter.blank?
    render "admin/helpers/remove_filter_link"
  end

  ##
  # If there's a partial with a "microformat" of the data we want to 
  # display, this will be used, otherwise we use a default table which 
  # it's build from the options defined on the yaml configuration file.
  #
  def build_list(model, fields, items, resource = @resource[:self], link_options = {}, association = nil)

    template = "app/views/admin/#{resource}/_#{resource.singularize}.html.erb"

    if File.exist?(template)
      render :partial => template.gsub('/_', '/'), :collection => items, :as => :item
    else
      build_typus_table(model, fields, items, link_options, association)
    end

  end

  def pagination(*args)
    @options = args.extract_options!
    render "admin/helpers/pagination" if @items.prev || @items.next
  end

end
