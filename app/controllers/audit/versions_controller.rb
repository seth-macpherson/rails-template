class Audit::VersionsController < BaseResourcesController
  protected

  def load_resources
    scope = policy_scope(PaperTrail::Version).includes(:item)
    scope = scope.where(item_type: params[:item_type].singularize.camelize) if params.key? :item_type
    scope = scope.where(item_id: params[:item_id]) if params.key? :item_id
    scope.order(id: :desc)
  end

  def load_resource
    model_class_name = params[:item_type].camelize
    record_id = params[:item_id]
    PaperTrail::Version.find_by(item_type: model_class_name, item_id: record_id)
  end

  def resource_name
    'version'
  end

  def resources_name
    'versions'
  end

  def resource_class_name
    'PaperTrail::Version'
  end
end
