# RSpec helpers to make JSON testing a bit easier. The structure of JSONAPI
# is consistent so we can help wrap or create objects
module JSONAPI
  def jsonapi_attributes_for(factory_name)
    factory = FactoryGirl.factory_by_name(factory_name)
    type = factory.build_class
    attrs = FactoryGirl.attributes_for(factory_name)

    # setup base payload for the model's attributes
    payload = {
      data: {
        type: type.model_name.plural,
        attributes: attrs
      }
    }

    # for each association, create the association record and add its
    # ID to the relationships object
    factory.associations.each do |assoc|
      payload[:data][:relationships] ||= {}

      assoc_factory = FactoryGirl.factory_by_name(assoc.factory)
      assoc_record = FactoryGirl.create(assoc.factory)
      payload[:data][:relationships][assoc.name] = {
        data: {
          type: assoc_factory.build_class.model_name.route_key.dasherize,
          id: assoc_record.id
        }
      }
    end

    # dasherize the keys to satisfy jsonapi format
    payload.deep_dasherize_keys
  end
end

RSpec.configure do |c|
  c.include JSONAPI
end
