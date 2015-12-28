module FormHelper
  def mmt_text_field(options)
    options[:name] = add_pipes(options[:name])

    classes = ['full-width']
    classes << 'validate' if options[:validate]
    classes << options[:classes]

    text_field_html = text_field_tag(
      name_to_param(options[:prefix] + options[:name]),
      options[:value],
      class: classes.join(' '),
      data: { level: remove_pipes(options[:prefix]) }
    )

    label(options) + help_icon(options) + text_field_html
  end

  def mmt_select(options)
    options[:name] = add_pipes(options[:name])

    classes = "half-width #{remove_pipes(options[:name])}-select"
    select_html = select_tag(
      name_to_param(options[:prefix] + options[:name]),
      options_for_select(options[:options], options[:value]),
      class: classes,
      prompt: "Select #{options[:title]}",
      data: { level: remove_pipes(options[:prefix]) }
    )

    label(options) + help_icon(options) + select_html
  end

  def label(options)
    options[:name] = add_pipes(options[:name])
    id = remove_pipes(options[:prefix] + options[:name]) if options[:set_id]
    label_for = id.nil? ? remove_pipes(options[:prefix] + options[:name]) : nil

    classes = 'required' if options[:required]
    label_tag(
      label_for,
      options[:title],
      class: classes,
      id: id
    )
  end

  def help_icon(options)
    return unless options[:help]
    link_to('#help-modal', class: 'display-modal', tabindex: -1) do
      "<i class=\"fa fa-info-circle\" data-help-path=\"#{options[:help]}\"></i><span class=\"is-hidden\">Help modal for #{options[:title]}</span>".html_safe
    end
  end

  def add_pipes(name)
    "|#{name}|"
  end
end
