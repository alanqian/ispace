module ProductsHelper
  def sales_status(product)
    status = I18n.t("dict.sale_type").invert[product.sale_type].to_s
    status += " #{t('dict.new_product')}" if product.new_product
    status += " #{t('dict.on_promotion')}" if product.on_promotion
    status
  end
end
