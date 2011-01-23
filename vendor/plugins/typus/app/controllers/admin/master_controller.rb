class Admin::MasterController < ApplicationController

  skip_filter filter_chain

  unloadable

  inherit_views 'admin/resources'

  layout 'admin'

  include Typus::Authentication
  include Typus::Format
  include Typus::Preferences
  include Typus::Reloader

  filter_parameter_logging :password

  before_filter :reload_config_and_roles

  before_filter :require_login

  before_filter :set_typus_preferences

  before_filter :set_resource
  before_filter :find_item, 
                :only => [ :show, :edit, :update, :destroy, :toggle, :position, :relate, :unrelate, :detach ]

  before_filter :check_ownership_of_item, 
                :only => [ :edit, :update, :destroy, :toggle, :position, :relate, :unrelate ]

  before_filter :check_if_user_can_perform_action_on_user, 
                :only => [ :edit, :update, :toggle, :destroy ]
  before_filter :check_if_user_can_perform_action_on_resource

  before_filter :set_order, 
                :only => [ :index ]
  before_filter :set_fields, 
                :only => [ :index, :new, :edit, :create, :update, :show ]

  ##
  # This is the main index of the model. With filters, conditions 
  # and more.
  #
  # By default application can respond_to html, csv and xml, but you 
  # can add your formats.
  #
  def index

    @conditions, @joins = @resource[:class].build_conditions(params)

    check_ownership_of_items if @resource[:class].typus_options_for(:only_user_items)

    respond_to do |format|
      format.html { generate_html }
      @resource[:class].typus_export_formats.each do |f|
        format.send(f) { send("generate_#{f}") }
      end
    end

  rescue Exception => error
    error_handler(error)
  end

  def new

    check_ownership_of_referal_item

    item_params = params.dup
    %w( controller action resource resource_id back_to selected ).each do |param|
      item_params.delete(param)
    end

    @item = @resource[:class].new(item_params.symbolize_keys)

  end

  ##
  # Create new items. There's an special case when we create an 
  # item from another item. In this case, after the item is 
  # created we also create the relationship between these items. 
  #
  def create

    @item = @resource[:class].new(params[@object_name])

    if @resource[:class].typus_user_id?
      @item.attributes = { Typus.user_fk => @current_user.id }
    end

    if @item.valid?
      create_with_back_to and return if params[:back_to]
      @item.save
      flash[:success] = _("%{model} successfully created.", 
                          :model => @resource[:human_name])
      if @resource[:class].typus_options_for(:index_after_save)
        redirect_to :action => 'index'
      else
        redirect_to :action => @resource[:class].typus_options_for(:default_action_on_item), :id => @item.id
      end
    else
      render :action => 'new'
    end

  end

  def edit
  end

  def show

    check_ownership_of_item and return if @resource[:class].typus_options_for(:only_user_items)

    respond_to do |format|
      format.html
      format.xml do
        fields = @resource[:class].typus_fields_for(:xml).collect { |i| i.first }
        render :xml => @item.to_xml(:only => fields)
      end
    end

  end

  def update

    if @item.update_attributes(params[@object_name])

      if @resource[:class].typus_user_id? && @current_user.is_not_root?
        @item.update_attributes Typus.user_fk => @current_user.id
      end

      path = if @resource[:class].typus_options_for(:index_after_save)
               params[:back_to] ? "#{params[:back_to]}##{@resource[:self]}" : { :action => 'index' }
             else
               { :action => @resource[:class].typus_options_for(:default_action_on_item), :id => @item.id, :back_to => params[:back_to] }
             end

      # Reload @current_user when updating to see flash message in the 
      # correct locale.
      if @resource[:class].eql?(Typus.user_class)
        I18n.locale = @current_user.reload.preferences[:locale]
        @resource[:human_name] = params[:controller].extract_human_name
      end

      flash[:success] = _("%{model} successfully updated.", 
                          :model => @resource[:human_name])
      redirect_to path

    else
      render :action => 'edit'
    end

  end

  def destroy
    @item.destroy
    flash[:success] = _("%{model} successfully removed.", 
                        :model => @resource[:human_name])
    redirect_to request.referer || admin_dashboard_path
  rescue Exception => error
    error_handler(error, params.merge(:action => 'index', :id => nil))
  end

  def toggle
    @item.toggle(params[:field])
    @item.save!
    flash[:success] = _("%{model} %{attribute} changed.", 
                        :model => @resource[:human_name], 
                        :attribute => params[:field].humanize.downcase)
    redirect_to request.referer || admin_dashboard_path
  end

  ##
  # Change item position. This only works if acts_as_list is 
  # installed. We can then move items:
  #
  #   params[:go] = 'move_to_top'
  #
  # Available positions are move_to_top, move_higher, move_lower, 
  # move_to_bottom.
  #
  def position
    @item.send(params[:go])
    flash[:success] = _("Record moved %{to}.", 
                        :to => params[:go].gsub(/move_/, '').humanize.downcase)
    redirect_to request.referer || admin_dashboard_path
  end

  ##
  # Relate a model object to another, this action is used only by the 
  # has_and_belongs_to_many and has_many relationships.
  #
  def relate
    resource_class = params[:related][:model].constantize    
    resource_tableized = params[:related][:relation] || params[:related][:model].tableize

    if @item.send(resource_tableized) << resource_class.find(params[:related][:id])
      flash[:success] = _("%{model_a} related to %{model_b}.", 
                        :model_a => resource_class.typus_human_name, 
                        :model_b => @resource[:human_name])
    else
      # TODO: Show the reason why cannot be related showing model_a and model_b errors.
      flash[:error] = _("%{model_a} cannot be related to %{model_b}.", 
                        :model_a => resource_class.typus_human_name, 
                        :model_b => @resource[:human_name])
    end

    redirect_to :back

  end


  ##
  # Remove relationship between models, this action never removes items!
  #
  def unrelate

    resource_class = params[:resource].classify.constantize
    resource_tableized = params[:resource].tableize
    resource = resource_class.find(params[:resource_id])

    if @resource[:class].
       reflect_on_association(resource_class.table_name.singularize.to_sym).
       try(:macro) == :has_one
      attribute = resource_tableized.singularize
      saved_succesfully = @item.update_attribute attribute, nil
    else
      attribute = resource_tableized
      saved_successfully =  if @item.respond_to?(attribute)
                              @item.send(attribute).delete(resource)
                            elsif @item.respond_to?("related_#{attribute}")
                              @item.relationships.detect {|rel| 
                                rel.related_id == resource.id && 
                                  rel.related_type == resource.class.name
                              }.destroy
                            end
    end

    if saved_succesfully
      flash[:success] = _("%{model_a} unrelated from %{model_b}.", 
                          :model_a => resource_class.typus_human_name, 
                          :model_b => @resource[:human_name])
    else
      # TODO: Show the reason why cannot be unrelated showing model_a and model_b errors.
      flash[:error] = _("%{model_a} cannot be unrelated to %{model_b}.", 
                        :model_a => resource_class.typus_human_name, 
                        :model_b => @resource[:human_name])
    end

    redirect_to :back

  end

  def detach

    attachment = @resource[:class].human_attribute_name(params[:attachment])

    if @item.update_attributes(params[:attachment] => nil)
      flash[:success] = _("%{attachment} removed.", 
                          :attachment => attachment)
    else
      flash[:notice] = _("%{attachment} can't be removed.", 
                         :attachment => attachment)
    end

    redirect_to :back

  end

  def current_user
    @current_user
  end

private

  def set_resource
    @resource = { :self => params[:controller].extract_resource, 
                  :human_name => params[:controller].extract_human_name, 
                  :class => params[:controller].extract_class,
                  :pluralized => params[:controller].extract_class.pluralized_human_name }
    @object_name = ActionController::RecordIdentifier.singular_class_name(@resource[:class])
  rescue Exception => error
    error_handler(error)
  end

  ##
  # Find model when performing an edit, update, destroy, relate, 
  # unrelate ...
  #
  def find_item
    @item = @resource[:class].find(params[:id])
  end

  ##
  # If item is owned by another user, we only can perform a 
  # show action on the item. Updated item is also blocked.
  #
  #   before_filter :check_ownership_of_item, :only => [ :edit, :update, :destroy, 
  #                                                      :toggle, :position, 
  #                                                      :relate, :unrelate ]
  #
  def check_ownership_of_item

    # By-pass if current_user is root.
    return if @current_user.is_root?

    condition_typus_users = @item.respond_to?(Typus.relationship) && !@item.send(Typus.relationship).include?(@current_user)
    condition_typus_user_id = @item.respond_to?(Typus.user_fk) && !@item.owned_by?(@current_user)

    if condition_typus_users || condition_typus_user_id
       flash[:notice] = _("You don't have permission to access this item.")
       redirect_to request.referer || admin_dashboard_path
    end

  end

  def check_ownership_of_items

    # By-pass if current_user is root.
    return if @current_user.is_root?

    # Show only related items it @resource has a foreign_key (Typus.user_fk) 
    # related to the logged user.
    if @resource[:class].typus_user_id?
      condition = { Typus.user_fk => @current_user }
      @conditions = @resource[:class].merge_conditions(@conditions, condition)
    end

  end

  def check_ownership_of_referal_item
    return unless params[:resource] && params[:resource_id]
    klass = params[:resource].classify.constantize
    return if !klass.typus_user_id?
    item = klass.find(params[:resource_id])
    raise "You're not owner of this record." unless item.owned_by?(@current_user) || @current_user.is_root?
  end

  def set_fields

    mapping = case params[:action]
              when 'index' then :list
              when 'new', 'edit', 'create', 'update' then :form
              else params[:action]
              end

    @fields = @resource[:class].typus_fields_for(mapping)

  end

  def set_order
    params[:sort_order] ||= 'desc'
    @order = params[:order_by] ? "#{@resource[:class].table_name}.#{params[:order_by]} #{params[:sort_order]}" : @resource[:class].typus_order_by
  end

  ##
  # When <tt>params[:back_to]</tt> is defined this action is used.
  #
  # - <tt>has_and_belongs_to_many</tt> relationships.
  # - <tt>has_many</tt> relationships (polymorphic ones).
  #
  def create_with_back_to

    if params[:resource] && params[:resource_id]
      resource_class = params[:resource].classify.constantize
      resource_id = params[:resource_id]
      resource = resource_class.find(resource_id)
      association = @resource[:class].reflect_on_association(params[:resource].to_sym).macro rescue :polymorphic
    else
      association = :has_many
    end

    case association
    when :belongs_to
      @item.save
    when :has_and_belongs_to_many
      @item.save
      @item.send(params[:resource]) << resource
    when :has_many
      @item.save
      message = _("%{model} successfully created.", 
                  :model => @resource[:human_name])
      path = "#{params[:back_to]}?#{params[:selected]}=#{@item.id}"
    when :polymorphic
      resource.send(@item.class.name.tableize).create(params[@object_name])
    end

    flash[:success] = message || _("%{model_a} successfully assigned to %{model_b}.", 
                                   :model_a => @item.class.typus_human_name, 
                                   :model_b => resource_class.typus_human_name)
    redirect_to path || params[:back_to]

  end

  def error_handler(error, path = admin_dashboard_path)
    raise error unless Rails.env.production?
    flash[:error] = "#{error.message} (#{@resource[:class]})"
    redirect_to path
  end

  include Typus::MasterControllerExtensions rescue nil
end
