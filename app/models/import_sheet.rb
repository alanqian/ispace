# encoding: utf-8
require 'csv'
require "roo"

class ImportSheet < ActiveRecord::Base
  validates :upload_sheet, presence: true, on: :create
  validates :sheets, presence: true, on: :create
  validates :comment, presence: true, on: :create

  validates :category_id, presence: true, on: :update
  validate :choose_at_least_one_no_empty_sheets, on: :update, if: "step == 2"

  validate :map_fields_check_requied, on: :update, if: "step == 3"

  serialize :sheets, Array
  serialize :sel_sheets, Array
  serialize :mapping, Hash
  serialize :imported, Hash

  def sel_sheets=(sel)
    sel.reject! { |v| v.empty? }
    sel.map! { |v| v.to_i }
    logger.debug "before assign, sel_sheets=#{sel_sheets}"
    super(sel)
    logger.debug "assigned, sel_sheets=#{sel_sheets} category_id=#{category_id}"
    if self.category_id.present?
      self.sel_sheets.each do |id|
        self.sheets[id][:category_id] = self.category_id
      end
      logger.debug "sel_sheets/category have been updated to sheets"
    end
  end

  def mapping=(param)
    logger.debug "before assign, mapping:#{self.mapping} param:#{param}"
    # TODO: strip nil value
    m = param.to_hash.reject { |k,v| v.empty? }
    super(m)
    logger.debug "assigned, mapping:#{self.mapping} param:#{m}"
  end

  def choose_at_least_one_no_empty_sheets
    logger.debug "validate :choose_at_least_one_no_empty_sheets!"
    count = sel_sheets.count do |id|
      id >= 0 && id < self.sheets.size && !self.sheets[id][:empty]
    end
    if count > 0
      return true
    else
      self.errors[:sel_sheets] << "请至少选择一个非空的工作表"
      return false
    end
  end

  def map_fields_check_requied
    logger.debug "validate map_fields_check_requied"

    fields = @@dict[:_required].reject { |k,v| mapping.has_value?(k) }
    if fields.empty?
      return true
    else
      self.errors[:mapping] << "必须映射下列字段：#{fields.values.join(",")}"
      return false
    end
  end

  before_update do
    case self.step
    when 2
      self.step = 3
    when 3
      # TODO: check required fields
      # ???: step to 0
      self.step = 4
    end
    logger.debug "before_update, #{self.sel_sheets}"
    logger.debug "before_update, #{self.to_json}"
  end

  # :message => "Please upload csv, xls, xlsx file!"
  # fake method for rails
  def upload_sheet
    self.filename
  end

  def upload_sheet=(sheet_field)
    logger.debug "upload_sheet, user_id: #{self.user_id}"
    self.filename = base_part_of(sheet_field.original_filename)
    self.ext = File.extname(self.filename).downcase
    self.sheets = load_xls(sheet_field)
    if self.sheets && !self.sheets.empty?
      self.step = 2
      # save to local file system, as backup
      #FileUtils.mkdir_p(File.dirname(local_file))
      #File.open(local_file, 'wb') { |f| f.write sheet_field.read }
      logger.debug "upload_sheet ok, filename:#{sheet_field.original_filename}"
    end
  rescue
    self.errors[:upload_sheet] << "failed to open sheet: #{sheet_field.original_filename}"
    logger.debug "upload_sheet failed, filename:#{sheet_field.original_filename}"
  end

  def sheet_fields
    fields = []
    sheets.each do |sheet|
      if sheet[:category_id] && !sheet[:empty]
        fields += sheet[:header].select { |e| e }
      end
    end
    fields.uniq
  end

  # finish the import task
  def finalize
    return if mapping.empty?
    # TODO: get user id from session

    self.imported = {
      supplier: 0,
      manufacturer: 0,
      merchandise: 0,
      brand: 0,
      product: 0,
    }
    self.sheets.each do |sheet|
      next if sheet[:empty] || !sheet[:category_id]

      # get the mapping
      map = []
      sheet[:header].each do |field|
        map.push mapping[field]
      end

      sheet[:cells].each do |row|
        category_id = sheet[:category_id]
        params = {
          supplier: {},
          manufacturer: {},
          merchandise: {},
          brand: {},
          product: {},
        }

        for i in 0..(map.size-1)
          to_field = map[i]
          if to_field
            table, field = to_field.split(".")
            params[table.to_sym][field.to_sym] = row[i]
          end
        end
        # logger.debug "import ok: #{params.to_json}"
        [:supplier, :manufacturer, :brand].each do |k|
          if not params[k].empty?
            klass = k.to_s.camelize.constantize
            params[k]["category_id"] = category_id
            r = klass.where(params[k])
            if r.empty?
              params[k][:id] = klass.create(params[k]).id
              self.imported[k] += 1
            else
              params[k][:id] = r.first.id
            end
          end
        end

        # create product
        params[:product].merge! ({
          category_id: category_id,
          brand_id: params[:brand][:id],
          mfr_id: params[:manufacturer][:id],
          user_id: self.user_id,
          import_id: self.id,
        })
        strip_dot_zero(params, :product)

        # logger.debug "import product: #{params[:product].to_json}"
        r = Product.where({code: params[:product][:code]})
        if r.empty?
          params[:product][:id] = Product.create(params[:product]).id
          self.imported[:product] += 1
        else
          # TODO: update?
          params[:product][:id] = r.first.id
        end

        # create merchandise
        # TODO: rcmd/min/max face
        params[:merchandise].merge! ({
          store_id: self.store_id,
          user_id: self.user_id,
          product_id: params[:product][:id],
          supplier_id: params[:supplier][:id],
          import_id: self.id,
        })
        strip_dot_zero(params, :merchandise)

        logger.debug "import merchandise: #{params[:merchandise].to_json}"
        r = Merchandise.where({product_id: params[:product][:id], import_id:
                              self.id})
        if r.empty?
          mcds = Merchandise.create(params[:merchandise])
          self.imported[:merchandise] += 1
          logger.debug "merchandise imported, id:#{mcds.id}"
        else
          # TODO: update?
        end
      end
    end
    self.step = 0
    self.save
  end

  def discard
    if self.step == 0 && !self.imported.empty?
      if imported[:brand] > 0
        Brand.delete_all(["import_id=?", self.id])
      end
      if imported[:supplier] > 0
        Supplier.delete_all(["import_id=?", self.id])
      end
      if imported[:manufacturer] > 0
        Manufacturer.delete_all(["import_id=?", self.id])
      end
      if imported[:product] > 0
        Product.delete_all(["import_id=?", self.id])
      end
      if imported[:merchandise] > 0
        Merchandise.delete_all(["import_id=?", self.id])
      end

      self.imported.clear
      self.step = 3
      self.save
    end
  end

  # make a patch for roo, for string fields
  def strip_dot_zero(params, table)
    klass = table.to_s.camelize.constantize
    # logger.debug klass
    params[table].each do |k, v|
      # logger.debug "table: #{table}, field:#{k}"
      column = klass.columns_hash[k.to_s]
      if column && column.type == :string
        s = params[table][k].to_s
        params[table][k] = s.sub(/\.0+/, '')
      end
    end
  end

  private
  def local_file
    Ispace::Application.config.sheet_dir + self.filename
  end

  def base_part_of(file_name)
    File.basename(file_name) # .gsub(/[^\w._-]/, '')
  end

  def load_xls(file)
    xls = self.class.open_spreadsheet(file, self.ext)
    sheets = []
    id = 0
    xls.sheets.each do |sheet|
      xls.default_sheet = sheet
      if xls.last_row && xls.last_column
        # not empty
        row_1st = xls.first_row
        rows = xls.last_row
        sheets.push({
          empty: false,
          id: id,
          name: sheet,
          rows: rows,
          columns: xls.last_column,
          thead: self.class.sheet_header(xls.last_column),
          header: xls.row(row_1st),
          cells: (row_1st+1).upto(rows).map { |i| xls.row(i) }
        })
      else
        # empty sheet
        sheets.push({
          empty: true,
          id: id,
          name: sheet,
          thead: ("A".."O").to_a,
        })
      end
      id += 1
    end
    return sheets
  end

  public
  def self.sheet_header(count)
    # AZEncoding:
    # A..Z, AA..AZ...ZZ, AAA...AAZ...ZZZ;
    # 26, 26 * 26, 26 * 26 * 26
    headers = []
    a = "A"
    z = "Z"
    while count > 0
      list = (a..z).to_a
      len = [count, list.size].min
      headers.concat(list[0..count-1])
      count -= len
      a += "A"
      z += "Z"
    end
    return headers
  end

  def self.open_spreadsheet(file, ext)
    case ext
    when '.csv' then Roo::Csv.new(file.path)
    when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
    when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown uploaded type: #{file.original_filename}"
    end
  end

  # returns hash of name => [value, label]
  def self.auto_mapping
    @@dict[:_mapping]
  end

  def self.mapping_fields
    @@dict[:_fields]
  end

  def self.init_dict(dict, init_mapping)
    def_mapping = {}
    fields = []
    dict.each do |table, map|
      map.each do |k, v|
        def_mapping[v] = "#{table}.#{k}"
        fields.push ["#{table}.#{k}", v]
      end
    end

    init_mapping.each do |k, v|
      cat, field = v.split(".")
      label = dict[cat.to_sym][field.to_sym]
      def_mapping[k] = v
      fields.push [v, label]
    end

    dict[:_mapping] = def_mapping
    dict[:_fields] = fields.uniq
    dict[:_required] = {
      "product.code" => "产品标识",
      "product.name" => "产品名称",
      "product.height" => "高度",
      "product.width" => "宽度",
      "product.depth" => "深度",
    }
    dict
  end

  @@dict = self.init_dict({
    product: {
      code: "产品标识",
      name: "产品名称",
      height: "高度",
      width: "宽度",
      depth: "深度",
      weight: "重量",
      price_level: "价格带",
      size_name: "规格(大小)",
      case_pack_name: "包装",
      bar_code: "条形码",
      color: "颜色",
    },

    brand: {
      name: "品牌",
    },

    merchandise: {
      price: "价格",
      new_product: "新品",
      on_promotion: "促销",
      force_on_shelf: "强制上架",
      forbid_on_shelf: "强制下架",
      max_facing: "最大排面数",
      min_facing: "最小排面数",
      rcmd_facing: "推荐排面数",
      volume: "销售速度",
      vulume_rank: "销售速度排名",
      value: "销售额",
      value_rank: "销售额排名",
      profit: "利润",
      profit_rank: "利润排名",
      psi: "PSI",
      psi_rank: "PSI排名",
    },

    supplier: {
      name: "供应商",
    },

    manufacturer: {
      name: "生产商",
    }}, {
      # customized mapping add here
      "名称" => "product.name",
      "大小" => "product.size_name",
    })
end

__END__

#!/usr/bin/env ruby
# encoding: utf-8
require 'roo'

class WorkBook
  # sheets
  # headers: fields
  # data: array of hash: by header, by column
  SheetInfo = Struct.new :name, :header, :rows, :columns, :records


  def initialize(file_path)
    file_path =~ /\.[a-zA-Z0-9]+$/
    ext = $&
    case ext.downcase
    when '.xls'
      @xls = Roo::Excel.new(file_path)
    when ".xlsx"
      @xls = Roo::Excelx.new(file_path)
    end
    load_sheets
  end

  # for empty sheet, last_row,last_column == nil
  # row,column based on 1
  def load_sheets
    @sheets = []
    return unless @xls
    @xls.sheets.each do |sheet|
      @xls.default_sheet = sheet
      si = SheetInfo.new
      si.name = sheet
      if @xls.last_row && @xls.last_column
        si.rows = @xls.last_row
        si.columns = @xls.last_column
        si.header = @xls.row(1)
      else
        si.rows = si.columns = 0
      end
      @sheets.push si
    end
  end
  private :load_sheets

  # https://github.com/Empact/roo
  def test
    @sheets.each { |sheet| puts "#{sheet.name}: #{sheet.rows} #{sheet.columns} #{sheet.header}" }

    # enum the sheets by array of hash
    @xls.default_sheet = @xls.sheets[0]
    @xls.each(:id => '产品标识', :name=>"名称") do |h|
      # puts h
    end
  end

  def test_dict
    mapping = @@dict[:_mapping]

    field_mapping = {
      "产品标识" => "product.id",
      "名称" => "product.name",
      "宽度" => "product.width",
      "高度" => "product.height",
      "深度" => "product.depth",
      "供应商" => "supplier.name",
      "大小" => "product.size_name",
      "品牌" => "brand.name",
      "利润" => "merchandise.profit",
      "销售速度" => "merchandise.volume",
      "销售额" => "merchandise.value",
      "价格" => "merchandise.price",
      "价格带" => "merchandise.price_level",
      "新品" => "merchandise.new_product",
    }
    field_mapping.each do |k,v|
      puts "#{k} : #{mapping[k]} : #{v}"
    end
  end

  def import_row(category_id, store_id, user_id)
    # field.strip!
    # product_id: check product.id: create if not exist,
    #             create brand, manufacturer if necessary
    # supplier_id: create supplier if necessary
    # create merchandise
  end
end

if __FILE__ == $0
  workbook = WorkBook.new("./test.xls")
  workbook.test_dict
end

__END__

field_mapping: {
  "产品标识" => "product.id",
  "名称" => "product.name",
  "宽度" => "product.width",
  "高度" => "product.height",
  "深度" => "product.depth",
  "供应商" => "supplier.name",
  "大小" => "product.size_name",
  "品牌" => "brand.name",
  "利润" => "merchandise.profit",
  "销售速度" => "merchandise.volume",
  "销售额" => "merchandise.value",
  "价格" => "merchandise.price",
  "价格带" => "merchandise.price_level",
  "新品" => "merchandise.new_product",
},

