require 'csv'
require "roo"

class ImportSheet < ActiveRecord::Base
  validates :upload_sheet, presence: true
  validates :data, presence: true

  # :message => "Please upload csv, xls, xlsx file!"
  # fake method for rails
  def upload_sheet
    self.filename
  end

  def upload_sheet=(sheet_field)
    logger.debug "upload_sheet, user_id: #{self.user_id}"
    self.filename = base_part_of(sheet_field.original_filename)
    self.ext = File.extname(self.filename).downcase
    xls = load_xls(sheet_field)
    if xls
      self.step = 2
      self.data = xls.to_json
      # save to local file system, as backup
      FileUtils.mkdir_p(File.dirname(local_file))
      File.open(local_file, 'wb') { |f| f.write sheet_field.read }
      logger.debug "upload_sheet ok, filename:#{sheet_field.original_filename}"
    end
  rescue
    logger.debug "upload_sheet failed, filename:#{sheet_field.original_filename}"
  end

  # readonly
  def sheets
    self.data ? JSON.parse(self.data) : nil
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
    id = 1
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
          cells: row_1st.upto(rows).map { |i| xls.row(i) }
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
  def self.init_dict(dict)
    mapping = {}
    dict.each do |table, map|
      map.each do |k, v|
        mapping[v] = "#{table}.#{k}"
      end
    end
    dict[:_mapping].merge!(mapping)
    dict
  end

  @@dict = self.init_dict({
    product: {
      id: "产品标识",
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
    },
    _mapping: {
      "名称" => "product.name",
      "大小" => "product.size_name",
    },
  })


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

