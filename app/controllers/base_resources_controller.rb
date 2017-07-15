# Most controllers operate in a standard way for CRUD operations. This DRYs that
# up by containing standard controller logic. Controllers are free to override
# anything or add more actions of course
class BaseResourcesController < ApplicationController
  before_action :set_resources, only: %i(index)
  before_action :set_resource, except: %i(index new create)
  before_action :set_parent, only: %i(index new create), if: :parent_data

  # Declare a 'belongs_to' class method that allows us to specify that this
  # controller is shallow nested under a parent. Example:
  #
  # class OrderItemsController < BaseResourcesController
  #   belongs_to :order
  # end
  #
  # When doing this, the following happen:
  #
  # #index: Automatically filtered to records belonging to the parent
  # #new, #create: The parent property on the resource is set to the parent
  #                record we found in the route. ex) @order_item.order = @order
  class << self
    attr_accessor :parent_data, :eager_load_config

    def belongs_to(model_name, options = {})
      @parent_data ||= {}
      @parent_data[:model_name] = model_name
      @parent_data[:model_class] = model_name.to_s.classify.constantize
      @parent_data[:find_by] = options[:find_by] || :id
      @parent_data[:find_by_param] = "#{model_name}_#{@parent_data[:find_by]}".to_sym
    end

    def eager_load(action, *options)
      @eager_load_config ||= {}
      @eager_load_config[action] = options
    end
  end

  def index
    set_resources

    respond_to do |format|
      format.html
      format.json
    end
  end

  def show
    authorize resource
    if should_decorate?
      instance_variable_set("@#{resource_name}", resource.decorate)
    end
    respond_to do |format|
      format.html
      format.json
    end
  end

  def new
    # If the method was overriden and 'resource' was already setup, don't
    # overwrite it by building it from the parameters
    build_resource unless resource.present?

    # Set parent on the resource if configured
    resource.send("#{parent_data[:model_name]}=", parent) if parent_data

    authorize resource

    render :new
  end

  def create
    # If the method was overriden and 'resource' was already setup, don't
    # overwrite it by building it from the parameters
    build_resource unless resource.present?

    # Set parent on the resource if configured
    if parent_data
      # If this belongs to a parent record, set that attribute on this child
      resource.send("#{parent_data[:model_name]}=", parent)
    end

    authorize resource

    if resource.save
      set_flash_message
      redirect_to after_create_path
    else
      respond_with resource do |format|
        format.html { render :new }
        format.json { render json: { success: false, errors: resource.errors }, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize resource
    if resource.update(resource_params)
      set_flash_message
      respond_with resource do |format|
        format.html { redirect_to after_update_path }
        format.json { render json: resource }
      end
    else
      respond_with resource do |format|
        format.html { render :edit }
        format.json { render json: { success: false, errors: resource.errors }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize resource
    render :edit
  end

  def destroy
    authorize resource
    if resource.destroy
      set_flash_message
      respond_with resource do |format|
        format.html { redirect_to after_destroy_path }
        format.json { render status: :no_content }
      end
    else
      respond_with resource do |format|
        format.html { redirect_to after_destroy_path, alert: resource.errors.full_messages.join(', ') }
        format.json { render status: :forbidden }
      end
    end
  end

  protected

  # Expect that the policy will tell us which parameters are valid for
  # create and update
  def permitted_params
    policy(resource || resource_class.new).send("permitted_#{action_name}_attributes")
  end

  # To be overridden by inheriting controllers
  def after_write_path; end

  def after_destroy_path
    after_write_path || resource_index_locator
  end

  def after_update_path
    after_write_path || resource
  end

  def after_create_path
    after_write_path || resource
  end

  def set_flash_message
    return unless request.format.html?
    key = "base_resources.#{params[:action]}.notice"
    class_label = resource_class.model_name.human
    flash[:notice] = t(key, type: class_label)
  end

  def build_resource
    instance_variable_set("@#{resource_name}", resource_class.new(resource_params))
  end

  def resource
    instance_variable_get("@#{resource_name}")
  end

  def resource_params
    # For JSON API, we need to use the JSON API deserializer. The object is sent
    # in a specific format that the default system doesn't support
    # For any other kind of request use the standard parameter fetcher
    if request.format == 'application/vnd.api+json'
      ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: permitted_params)
    else
      return {} unless params.key? resource_name.to_sym
      params.require(resource_name.to_sym).permit(permitted_params)
    end
  end

  # Generates an array of parts to locate the resource when generating URLs
  # For example, [:admin, :accounts] where you'd do admin_accounts_path
  def resource_index_locator
    self.class.name.sub(/Controller$/, '').split('::').map(&:underscore).map(&:to_sym)
  end

  def eager_load(query)
    relations = (self.class.eager_load_config || {})[action_name.to_sym]
    relations.present? ? query.includes(relations) : query
  end

  # Used in the before_action callback to set the instance variable matching
  # the resource name and loading the resource from the database
  def set_resource
    instance_variable_set("@#{resource_name}", load_resource)
  end

  def set_resources
    scope = load_resources
    scope = scope.page(params[:page]) if should_paginate?
    scope = resource_class.decorator_class.decorate_collection(scope) if should_decorate?
    @resources_value = scope
    instance_variable_set("@#{resources_name}", @resources_value)
  end

  # Loads the resource from the database. If the resource uses FriendlyId,
  # we need to chain .friendly before .find
  def load_resource
    query = eager_load(resource_class)
    if resource_class.respond_to? :friendly_id
      query.friendly.find params[:id]
    else
      query.find params[:id]
    end
  end

  def load_resources
    resources_query = policy_scope(resource_class)
    resources_query = eager_load(resources_query)

    if parent_data
      # This is nested under a parent, so we need to filter it
      # This is equivalent of doing: OrderItem.where(order: @order)
      resources_query.where(Hash[parent_data[:model_name], parent])
    else
      resources_query.all
    end
  end

  def resource_class
    resource_class_name.constantize
  end

  def resource_class_name
    self.class.name.sub(/Controller$/, '').singularize
  end

  def resource_name
    resources_name.singularize
  end

  def resources_name
    # SeaHorsesController => sea_horses
    # Admin::Accounts => accounts
    self.class.name.split('::').last.sub(/Controller$/, '').underscore
  end

  def should_decorate?
    resource_class.decorator_class?
  end

  def should_paginate?
    request.format.html?
  end

  def parent_data
    self.class.parent_data
  end

  def parent
    instance_variable_get("@#{parent_data[:model_name]}")
  end

  def set_parent
    instance_variable_set("@#{parent_data[:model_name]}", load_parent)
  end

  def load_parent
    id = params[parent_data[:find_by_param]]

    if parent_data[:model_class].respond_to? :friendly_id
      parent_data[:model_class].friendly.find id
    else
      filter = Hash[parent_data[:find_by], id]
      parent_data[:model_class].send(:find_by!, filter)
    end
  end

  # Rubocop thinks this is an attribute accessor
  # rubocop:disable Style/AccessorMethodName
  def set_attachment_name(name)
    escaped = URI.encode(name)
    response.headers['Content-Disposition'] = "attachment; filename*=UTF-8''#{escaped}"
  end
end
