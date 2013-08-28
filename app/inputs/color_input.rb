class ColorInput < SimpleForm::Inputs::CollectionInput
  def input
    label_method, value_method = detect_collection_methods

    @builder.collection_select(
      attribute_name, collection, value_method, label_method,
      input_options, input_html_options
    )
  end

  def collection
    return I18n.t("dict.colors")
  end

  def input_options
    options = super
    options[:include_blank] = false
    options[:default] ||= I18n.t("dict.colors.default")
    options
  end

  def input_html_classes
    super.push("colorpicker")
  end
end

__END__

class ColorInput < SimpleForm::Inputs::Base
  def input
     "#{@builder.color_field(attribute_name, input_html_options)}".html_safe
  end

end

__END__

# http://guides.rubyonrails.org/form_helpers.html
<%= color_field(:brand, :color) %>
<%= f.select(:city_id, [['Lisbon', 1], ['Madrid', 2], ...]) %>

module SimpleForm
  module Inputs
    class CollectionSelectInput < CollectionInput
      def input
        label_method, value_method = detect_collection_methods

        @builder.collection_select(
          attribute_name, collection, value_method, label_method,
          input_options, input_html_options
        )
      end
    end
  end
end

Custom inputs

It is very easy to add custom inputs to SimpleForm. For instance, if you want to add a custom input that extends the string one, you just need to add this file:

# app/inputs/currency_input.rb
class CurrencyInput < SimpleForm::Inputs::Base
  def input
    "$ #{@builder.text_field(attribute_name, input_html_options)}".html_safe
  end
end

And use it in your views:

f.input :money, as: :currency

You can also redefine existing SimpleForm inputs by creating a new class with the same name. For instance, if you want to wrap date/time/datetime in a div, you can do:

# app/inputs/date_time_input.rb
class DateTimeInput < SimpleForm::Inputs::DateTimeInput
  def input
    template.content_tag(:div, super)
  end
end

Or if you want to add a class to all the select fields you can do:

# app/inputs/collection_select_input.rb
class CollectionSelectInput < SimpleForm::Inputs::CollectionSelectInput
  def input_html_classes
    super.push('chosen')
  end
end

