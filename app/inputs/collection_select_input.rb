# Collections. Things like dropdowns, radio lists, checkbox lists
class CollectionSelectInput < SimpleForm::Inputs::CollectionSelectInput
  def input_html_classes
    super.push('ui search selection dropdown')
  end
end
