# input category_id by a tree of category_name
class TreeInput < SimpleForm::Inputs::TextInput
  def input
    input_html_options[:data] ||= {}
    options[:data] ||= {}
    id_data_options = options[:data].merge(type: attribute_name)

    cmd = options.delete :cmd
    input_html_options[:data][:cmd] = cmd
    input_html_options[:data][:type] = attribute_name
    input_html_options.delete :cmd

    @builder.hidden_field(attribute_name, data: id_data_options) +
      @builder.text_field(label_target, input_html_options)
  end

  def input_html_classes
    super.push('ui-tree-input')
  end

  # set to *_name
  def label_target
    attribute_name.to_s.sub(/(_id)?$/, "_name").to_sym
  end
end
