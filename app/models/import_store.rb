class ImportStore < ImportSheet
  before_destroy :delete_imported

  def initialize(params_hash = {})
    @tables = {
      :region => Region,
      :store => Store,
    }
    super params_hash.merge({ob: "store"})
  end

  def on_upload
    self.imported[:count] = {
      :region => 0,
      :store => 0,
    }
  end

  def start_import?(sheet)
    @region_id = nil
    @region_pre = nil
    @store_id = nil
    @count = {
      :region => 0,
      :store => 0,
    }
    true
  end

  def import_row(params, row_index)
    region_params = params[:region]
    if region_params
      logger.debug "region: #{region_params}"
      if region_params[:code] && !region_params[:code].empty?
        if region_params[:code].start_with?(".")
          abbr_region = true
          region_params[:code] = "#{@region_pre}#{region_params[:code]}"
        else
          abbr_region = false
        end

        if valid_region_code?(region_params[:code])
          # import it!
          region_params[:consume_type] ||= "B"
          region_params[:import_id] = self.id
          Region.create(region_params)
          @region_id = region_params[:code]
          @region_pre = @region_id unless abbr_region
          @count[:region] += 1
        else
          # error row
          logger.warn "invalid region code, region:#{region_params}"
          return false
        end
      end
    end

    store_params = params[:store]
    if store_params
      logger.debug "store: #{store_params}"
      if store_params[:code] && store_params[:name]
        if @region_id
          store_params[:region_id] = @region_id
          store_params[:import_id] = self.id
          st = Store.create(store_params)
          @store_id = st.id
          @count[:store] += 1
        else
          logger.warn "no region, store:#{store_params}"
          return false
        end
      end
    end
    true
  end

  def end_import(sheet)
    imported[:count][:region] += @count[:region]
    imported[:count][:store] += @count[:store]
    true
  end

  def delete_imported
    count = imported[:count]
    @tables.each do |table, klass|
      if count[table] > 0
        klass.delete_all(["import_id=?", self.id])
        logger.debug "discard import #{klass}, import_id:#{id} count:#{count[table]}"
      end
    end
  end

  def self.map_dict
    @@dict
  end

  private
  def parent_region_code(code)
    pcode = code.sub(/\.[a-zA-Z0-9]+$/, '')
    return pcode if $&
    return nil
  end

  def valid_region_code?(code)
    pcode = parent_region_code(code)
    return true unless pcode
    return Region.exists?(pcode)
  end

  @@dict = load_dict("import_stores")
end
