# Helper methods that should be available across all views
module ApplicationHelper
  def page_title
    [content_for(:title), I18n.t(:site_title)].reject(&:blank?).join(' - ')
  end

  def site_name
    I18n.t(:site_name)
  end

  def body_classes
    [controller_path, action_name].map(&:parameterize)
  end

  def nav_link(type, link: nil, label: nil)
    link_to (link || resource_class(type.to_s)), class: 'item' do
      [
        content_tag(:i, nil, class: [t("nav.#{type}.icon"), :icon].join(' ')),
        label || t("nav.#{type}.label")
      ].sum
    end
  end

  def resource_class(type = nil)
    (type || controller_path).singularize.to_s.camelize.constantize
  end

  # Gets the human_attribute_name for an activerecord model
  # By default we assume it's an attribute for a model matching the current
  # controller name
  def attr_name(attr, model_name = nil)
    model_class = (model_name || controller_path.singularize).to_s.camelize.constantize
    model_class.human_attribute_name(attr)
  end

  def link_to_index(options = {})
    type = options[:type] || resource_class
    path = options[:path] || polymorphic_path(type)
    link_to path do
      [
        content_tag(:i, nil, class: 'arrow left icon'),
        t(".back_to_index", type: type.model_name.human(count: 2))
      ].sum
    end
  end

  # Creates a link to a record
  # The second argument can be a few things
  # string: used literally as the label
  # symbol: label method to use on the object. ex) link_to_record person, :email
  # nil (default): automatically try to find a sensible label method
  def link_to_record(record, label_or_method = nil)
    return nil if record.nil?

    label = label_or_method if label_or_method.is_a?(String)
    label = record.send(label_or_method) if label_or_method.is_a?(Symbol)
    label = record_label(record) if label.blank?

    link_to label, record
  end

  def record_label(record)
    candidates = %i(primary_description name title label description to_s)
    candidates.select { |m| record.respond_to?(m) }.each do |m|
      unless (result = record.send(m)).blank?
        return result
      end
    end
  end

  def timeago(time)
    return nil if time.nil?
    if time.is_a?(Date)
      # For dates, format as datestamp (YYYY-MM-DD) and add the date class
      # so the js can format it differently
      timestamp = l(time, format: :datestamp)
      css_class = 'date'
    else
      timestamp = l(time.utc, format: :timestamp)
      css_class = 'time'
    end
    content_tag(:time, timestamp, class: css_class, datetime: timestamp)
  end

  def new_record_button(type = nil, *args)
    type ||= controller_path.singularize.to_sym
    return nil unless policy(type).new?
    record_class = type.to_s.camelize.constantize
    options = args.extract_options!
    default_path = [:new, options.fetch(:parent, nil), record_class.model_name.param_key]

    path = options.fetch(:path, default_path)
    text = t('buttons.new_record', type: record_class.model_name.human)
    classes = %w(ui green icon button)

    contents = [
      content_tag(:i, nil, class: 'plus icon')
    ]

    label = options.fetch(:label, nil)
    if label == true
      contents << I18n.t('buttons.new_record', type: type.model_name.human)
    elsif label.is_a? String
      contents << label
    end
    classes << 'labeled' if label.present?

    link_to path, class: classes, title: text do
      contents.compact.sum
    end
  end

  def edit_record_button(record)
    return nil unless policy(record).edit?
    link_to [:edit, record], class: 'ui small blue icon button', title: I18n.t('buttons.edit') do
      content_tag(:i, nil, class: 'edit icon')
    end
  end

  def delete_record_button(record)
    return nil unless policy(record).destroy?
    link_attrs = {
      class:  'ui small red icon button',
      method: :delete,
      title:  I18n.t('buttons.destroy'),
      data:   {
        confirm: t('confirms.destroy', type: record.class.model_name.human.downcase)
      }
    }
    link_to record, link_attrs do
      content_tag(:i, nil, class: 'trash icon')
    end
  end

  def changelog_button(record)
    path = audit_record_versions_path(item_type: record.model_name.plural, item_id: record.id)
    link_to path, class: 'ui orange icon button', title: I18n.t('buttons.changelog') do
      content_tag(:i, nil, class: 'history icon')
    end
  end
end
