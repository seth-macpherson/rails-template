class PaperTrail::VersionDecorator < ApplicationDecorator
  delegate_all

  # For objects that don't have routes (like Identity), just return nil
  def item_path
    return nil if object.item.nil?
    begin
      h.polymorphic_path object.item
    rescue NoMethodError
      nil
    end
  end

  def item_description
    "#{basic_item_description}: #{object.item.decorate.primary_description}"
  rescue Draper::UninferrableDecoratorError, NoMethodError
    "#{object.item_type} ##{object.item_id}"
  end

  def basic_item_description
    "#{object.item_type} ##{object.item_id}"
  end

  def event_name
    object.event.titleize
  end

  def event_name_past
    key = {
      create:  :created,
      update:  :updated,
      destroy: :destroyed
    }[object.event.to_sym]
    h.t "actions.#{key}"
  end

  def event_icon
    {
      create:  :wizard,
      update:  :write,
      destroy: :trash
    }[object.event.to_sym]
  end

  def event_color
    {
      create:  :green,
      update:  :purple,
      destroy: :red
    }[object.event.to_sym]
  end

  def event_with_icon
    h.content_tag(:span, class: [:ui, event_color, :label]) do
      h.content_tag(:i, nil, class: [event_icon, :icon]) +
        h.content_tag(:span, event_name_past, class: 'name')
    end
  end

  def modified_by
    return h.t(:unknown) if object.whodunnit.blank?
    User.unscoped.find_by(id: object.whodunnit)
  end

  def diff_change(old_value, new_value)
    Diffy::SplitDiff.new(old_value, new_value, format: :html)
  end

  def attr_name(name)
    object.item_type.constantize.human_attribute_name(name)
  end

  def format_value(val)
    if val.is_a?(TrueClass)
      h.t(:yes)
    elsif val.is_a?(FalseClass)
      h.t(:no)
    elsif val.nil?
      h.content_tag(:em, h.t(:no_value))
    elsif val == ''
      h.content_tag(:em, h.t(:blank_value))
    else
      val
    end
  end

  def changeset
    object.changeset.reject { |_k, v| v.empty? }
  end
end
