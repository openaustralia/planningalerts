module TypusHelper

  def applications

    apps = ActiveSupport::OrderedHash.new

    Typus.applications.each do |app|

      available = Typus.application(app).map do |resource|
                    resource if @current_user.resources.include?(resource)
                  end.compact

      next if available.empty?

      apps[app] = available.sort_by { |x| x.constantize.typus_human_name }

    end

    render "admin/helpers/applications", :applications => apps

  end

  def resources

    available = Typus.resources.map do |resource|
                  resource if @current_user.resources.include?(resource)
                end.compact

    return if available.empty?

    render "admin/helpers/resources", :resources => available

  end

  def typus_block(*args)

    options = args.extract_options!

    partials_path = "admin/#{options[:location]}"
    resources_partials_path = 'admin/resources'

    partials = ActionController::Base.view_paths.map do |view_path|
      Dir["#{view_path.path}/#{partials_path}/*"].map { |f| File.basename(f, '.html.erb') }
    end.flatten
    resources_partials = Dir["#{Rails.root}/app/views/#{resources_partials_path}/*"].map { |f| File.basename(f, '.html.erb') }

    partial = "_#{options[:partial]}"

    path = if partials.include?(partial) then partials_path
           elsif resources_partials.include?(partial) then resources_partials_path
           end

    render "#{path}/#{options[:partial]}" if path

  end

  def page_title(action = params[:action])
    crumbs = []
    crumbs << @resource[:pluralized] if @resource
    crumbs << _(action.humanize) unless %w( index ).include?(action)
    return crumbs.compact.map { |x| x }.join(' &rsaquo; ').html_safe
  end

  def header

    links = []
    links << (link_to_unless_current _("Dashboard"), admin_dashboard_path)

    Typus.models_on_header.each do |model|
      links << (link_to_unless_current model.constantize.pluralized_human_name, :controller => "/admin/#{model.tableize}")
    end

    render "admin/helpers/header", :links => links

  end

  def login_info(user = @current_user)

    admin_edit_typus_user_path = { :controller => "/admin/#{Typus::Configuration.options[:user_class_name].tableize}", 
                                   :action => 'edit', 
                                   :id => user.id }

    message = _("Are you sure you want to sign out and end your session?")

    user_details = if user.can?('edit', Typus::Configuration.options[:user_class_name])
                     link_to user.name, admin_edit_typus_user_path, :title => "#{user.email} (#{user.role})"
                   else
                     user.name
                   end

    render "admin/helpers/login_info", :message => message, :user_details => user_details

  end

  def display_flash_message(message = flash)
    return if message.empty?
    flash_type = message.keys.first
    render "admin/helpers/flash_message", :flash_type => flash_type, :message => message
  end

end
