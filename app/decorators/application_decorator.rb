class ApplicationDecorator < Draper::Decorator
  def primary_description
    desc_method = %i(name title description to_s).first { |m| object.respond_to? m }
    object.send(desc_method)
  end

  def secondary_description?
    self.class.method_defined?(:secondary_description)
  end
end
