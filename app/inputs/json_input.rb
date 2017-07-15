# Handle 'json' data type which is typically a hash
# Without this input you'd get an ugly 'inspect' output in a text box
# that uses ruby hash rocket syntax which ends up being wrong on the postback
class JsonInput < SimpleForm::Inputs::TextInput
  def input(wrapper_options = nil)
    value = @builder.object.send(attribute_name)
    input_html_options[:value] = value.present? ? JSON.pretty_generate(value) : nil
    input_html_options[:type] = :textarea
    input_html_options[:class] = :json
    input_html_options[:data] = { cmlang: 'application/json' }
    super
  end
end
