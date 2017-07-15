# Adds buttons to the normal simple form
# A method name matches the first agrument given to the button method
# ex) `f.button :cancel` => cancel(*args, &block)
module ButtonComponents
  def cancel(*args, &block)
    options = args.extract_options!
    label = options.delete(:label) || I18n.t('simple_form.buttons.cancel')
    path = options.delete(:path) || object
    link_block = block || proc { label }

    template.link_to(path, class: 'ui secondary cancel button', &link_block)
  end
end

SimpleForm::FormBuilder.send :include, ButtonComponents
