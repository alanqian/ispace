module ApplicationHelper
  def tm(model)
    model ||= controller_name.classify.downcase
    return I18n.t "activerecord.attributes.#{model.downcase}"
  end

  def tf(field)
    model = controller_name.classify.downcase
    prefixs = ["activerecord.attributes.#{model}", "dict"]
    prefixs.each do |prefix|
      s = I18n.t("#{prefix}.#{field}", default: '')
      return s unless s.empty?
    end
    return I18n.t("#{prefixs[0]}.#{field}")
  end

  def color_tag(color)
    content_tag(:span, raw("&nbsp;"), class: "colorbox", style: "background-color: #{color};")
  end

  def rel_hash(rel_array, key, value)
    return Hash[* rel_array.map{|r| [r[key], r[value]]}.flatten]
  end
end
