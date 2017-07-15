# Handle 'point' data type which is typically geo coordinates
# Without this input you'd get an ugly 'inspect' output in a text box
# which is unusable. The Rails parser nicely accepts comma-separated values for
# points so we'll put that in the box.
class PointInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    value = @builder.object.send(attribute_name)
    input_html_options[:value] = value.present? ? "#{value.x},#{value.y}" : nil
    input_html_options[:type] = :text
    super
  end
end
