class ImportSale < ImportSheet
  before_destroy :delete_imported

  def on_upload
    self.imported[:count] = {
      :sale => 0,
    }
  end

  def start_import?(sheet)
    @count = 0
    @common = {
      store_id: self.store_id,
      user_id: self.user_id,
      import_id: self.id,
    }
  end

  def import_row(params, row_index)
    sale_params = params[:sale].merge @common
    product_id = params[:product][:code]
    if Product.exists?(product_id)
      sale_params[:product_id] = product_id
      sale_id = Sale.create(sale_params).id
      @count += 1
      logger.debug "sale imported, id:#{sale_id}, product_id:#{product_id}, import_id:#{self.id}"
      return true
    else
      logger.warn "sale imported failed, product_id:#{product_id}, import_id:#{self.id}"
      return false
    end
  end

  def end_import(sheet)
    self.imported[:count][:sale] += @count
    @count = 0
  end

  def delete_imported
    count = self.imported[:count][:sale]
    if count > 0
      Category.delete_all(["import_id=?", self.id])
      logger.debug "discard import Sale, import_id:#{id} count:#{count}"
    end
  end

  def self.map_dict
    @@dict
  end

  @@dict = load_dict("import_sales")
end
