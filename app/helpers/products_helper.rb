module ProductsHelper
  def sales_status(product)
    # status = I18n.t("dict.abbr_grades.#{product.grade}")
    status = product.new_product ? "#{t('dict.new_product')}" : ""
    status += "#{t('dict.on_promotion')}" if product.on_promotion
    status
  end
end
