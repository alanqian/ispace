class ImportStore < ImportSheet
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

  def import_region(params)
    names = params[:name]
    codes = params[:code]
    if names.size != 2 && codes != 2
      logger.debug "invalid region, name.size != 2 or code.size != 2"
      return nil
    end
    parent = Region.where(name: name[0]).first
    if parent.nil?
      Region.create()
    end
    node_id
  end

  def import_row(params, row_index)
    logger.debug "import_row store, row:#{row_index}, params: #{params.to_json}"
    region_params = params[:region]

    if region_params
      logger.debug "region: #{region_params}"
      regions = []
      parent = {
        code: region_params[:code][0],
        name: region_params[:name][0]
      }
      regions.push parent
      if region_params[:code].size == 2
        node = {
          code: region_params[:code].join("."),
          name: region_params[:name][1]
        }
        regions.push node
      end
      regions.each do |region_param|
        if region_param[:code] && !region_param[:code].empty?
          if Region.exists?(region_param[:code])
            @region_id = region_param[:code]
            logger.warn "duplicated region updated, code:#{region_param[:code]}"
            region_param[:consume_type] ||= "B"
            region_param[:import_id] = self.id
            Region.update(@region_id, region_param)
          elsif valid_region_code?(region_param[:code])
            # import it!
            region_param[:consume_type] ||= "B"
            region_param[:import_id] = self.id
            Region.create(region_param)
            @region_id = region_param[:code]
            @count[:region] += 1
          else
            # error row
            logger.warn "invalid region code, region:#{region_param}"
            return false
          end
        end
      end
    end

    store_params = params[:store]
    if store_params
      logger.debug "import store: #{store_params}"
      if store_params[:code] && store_params[:name]
        if Store.exists?(code: store_params[:code])
          logger.warn "dup store found, #{store_params}"
        elsif @region_id
          logger.debug "create store: #{store_params}"
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

  def self.map_dict
    @@dict
  end

  def self.import_tables
    imports = {
      :region => Region,
      :store => Store,
      # TODO: user?
    }
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
