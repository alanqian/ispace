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
end
