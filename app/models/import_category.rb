class ImportCategory < ImportSheet
  def on_upload
    imported[:count] = {
      category: [0, 0, 0]
    }
  end

  def start_import?(sheet)
    @count = [0, 0, 0]
    @importing = {}
    true
  end

  def import_row(params, row_index)
    category_params = params[:category]

    3.times do |i|
      if category_params[:code][i] && !category_params[:code][i].empty? &&
        category_params[:name][i] && !category_params[:name][i].empty?
        # do import
        if valid_category_code?(category_params[:code][i])
          @importing[category_params[:code][i]] = category_params[:name][i]
          @count[i] += 1
        else
          logger.warn "invalid category code: #{category_params[:code][i]}"
          return false
        end
      else
        # skip it
      end
    end
    true
  end

  def end_import(sheet)
    columns = [:code, :name, :parent_id, :import_id, :pinyin]
    values = []
    @importing.each do |code, name|
      pinyin = HanziToPinyin.hanzi_to_pinyin(name)
      values.push [code, name, parent_code(code), self.id, pinyin]
    end
    Category.import(columns, values)
    @importing.clear
    imported[:count][:category] = @count
    true
  end

  def self.map_dict
    @@dict
  end

  def self.import_tables
    imports = {
      category: Category
    }
  end

  private
  def parent_code(code)
    if code.size <= 2
      return nil
    else
      code[0..code.size-3]
    end
  end

  def valid_category_code?(code)
    pcode = parent_code(code)
    return true unless pcode
    return Category.exists?(pcode) || @importing[pcode]
  end

  @@dict = load_dict("import_categories")
end

