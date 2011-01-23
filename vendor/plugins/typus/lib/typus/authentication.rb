module Typus

  module Authentication

    protected

    # Require login checks if the user is logged on Typus, otherwise 
    # is sent to the sign in page with a :back_to param to return where 
    # she tried to go.
    def require_login

      # Uncomment the following line for demo purpouses.
      # session[:typus_user_id] = Typus.user_class.find(:first)

      if session[:typus_user_id]
        set_current_user
      else
        back_to = (request.env['REQUEST_URI'] == admin_dashboard_path) ? nil : request.env['REQUEST_URI']
        redirect_to admin_sign_in_path(:back_to => back_to)
      end

    end

    # Return the current user. If role does not longer exist on the 
    # system @current_user will be signed out from Typus.
    def set_current_user

      @current_user = Typus.user_class.find(session[:typus_user_id])

      unless Typus::Configuration.roles.has_key?(@current_user.role)
        raise _("Role does no longer exists.")
      end

      unless @current_user.status
        back_to = (request.env['REQUEST_URI'] == admin_dashboard_path) ? nil : request.env['REQUEST_URI']
        raise _("Typus user has been disabled.")
      end

    rescue Exception => error
      flash[:notice] = error.message
      session[:typus_user_id] = nil
      redirect_to admin_sign_in_path(:back_to => back_to)
    end

    # Action is available on: edit, update, toggle and destroy
    def check_if_user_can_perform_action_on_user

      return unless @item.kind_of?(Typus.user_class)

      current_user = (@current_user == @item)

      message = case params[:action]
                when 'edit'

                  # Only admin and owner of Typus User can edit.
                  if @current_user.is_not_root? && !current_user
                    _("As you're not the admin or the owner of this record you cannot edit it.")
                  end

                when 'update'

                  # current_user cannot change her role.
                  if current_user && !(@item.role == params[@object_name][:role])
                    _("You can't change your role.")
                  end

                when 'toggle'

                  # Only admin can toggle typus user status, but not herself.
                  if @current_user.is_root? && current_user
                    _("You can't toggle your status.")
                  elsif @current_user.is_not_root?
                    _("You're not allowed to toggle status.")
                  end

                when 'destroy'

                  # Admin can remove anything except herself.
                  if @current_user.is_root? && current_user
                    _("You can't remove yourself.")
                  elsif @current_user.is_not_root?
                    _("You're not allowed to remove Typus Users.")
                  end

                end

      if message
        flash[:notice] = message
        redirect_to request.referer || admin_dashboard_path
      end

    end

    # This method checks if the user can perform the requested action.
    # It works on models, so its available on the admin_controller.
    def check_if_user_can_perform_action_on_resource

      message = case params[:action]
                when 'index', 'show'
                  "%{current_user_role} can't display items."
                when 'destroy'
                  "%{current_user_role} can't delete this item."
                else
                  "%{current_user_role} can't perform action. (%{action})"
                end

      message = _(message, 
                  :current_user_role => @current_user.role.capitalize, 
                  :action => params[:action])

      unless @current_user.can?(params[:action], @resource[:class])
        flash[:notice] = message
        redirect_to request.referer || admin_dashboard_path
      end

    end

    # This method checks if the user can perform the requested action.
    # It works on resources, which are not models, so its available on 
    # the typus_controller.
    def check_if_user_can_perform_action_on_resource_without_model
      controller = params[:controller].split('/').last
      action = params[:action]
      unless @current_user.can?(action, controller.camelize, { :special => true })
        flash[:notice] = _("%{current_user_role} can't go to %{action} on %{controller}.",
                           :current_user_role => @current_user.role.capitalize, 
                           :action => action, 
                           :controller => controller.humanize.downcase)
        redirect_to request.referer || admin_dashboard_path
      end
    end

  end

end