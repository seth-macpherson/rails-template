module SimpleForm
  # Extend the 'disabled' feature of SimpleForm with reading permitted attributes
  # from the Pundit policy for the object we're updating
  module DisabledExtensions
    private

    # I didn't name this method, so don't yell at me for its name!
    # rubocop:disable Style/PredicateName
    def has_disabled?
      options.key?(:disabled) ? options[:disabled] : disabled_by_policy?
    end

    def disabled_by_policy?
      !(permitted_attributes.include?(attribute_name) || permitted_attributes.include?(reflection_or_attribute_name))
    end

    def permitted_attributes
      # load the Pundit policy for the object
      policy = template.controller.policy(object)

      # map action names
      action = template.controller.action_name.to_sym
      action = { edit: :update, new: :create }.fetch(action, action)

      # Get the list of permitted attributes as an array of attribute names
      # For attributes that permit array values, the entry is not a name, but
      # a hash with the key as the attribute name and a value of []
      # So for such cases, pluck the hash key as the name
      @permitted_attributes = policy.send("permitted_#{action}_attributes".to_sym)
                                    .map { |a| a.is_a?(Hash) ? a.keys.first : a }
    end
  end
end

SimpleForm::Inputs::Base.send :prepend, SimpleForm::DisabledExtensions
