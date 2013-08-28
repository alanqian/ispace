class ColorInput < SimpleForm::Inputs::Base
  def input
     "#{@builder.color_field(attribute_name, input_html_options)}".html_safe
  end
  # <%= color_field(:brand, :color) %>
end
