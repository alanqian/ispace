module ProductsHelper
  def sales_status(product)
    status = I18n.t("dict.sale_type")[product.sale_type]
    status += " #{t('dict.new_product')}" if product.new_product
    status += " #{t('dict.on_promotion')}" if product.on_promotion
    status
  end
end
