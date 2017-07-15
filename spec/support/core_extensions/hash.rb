# Extensions to the core Hash class
class Hash
  def deep_dasherize_keys
    deep_transform_keys { |k| k.to_s.dasherize.to_sym }
  end

  def deep_dasherize_keys!
    deep_transform_keys! { |k| k.to_s.dasherize.to_sym }
  end
end
