# encoding: utf-8
require 'csv'
require "roo"

class ImportSheet < ActiveRecord::Base
  serialize :sheets, Array
  serialize :mapping, Hash
  serialize :imported, Hash

  validates :type, presence: true
  validates :_do, presence: true
  validates :sheets, presence: true
  validates :comment, presence: true
  validates :file_upload, presence: true
  validate :validate_mapping
  validate :validate_sheets
  before_update :import
  before_destroy :discard_imported

  # fake method for view
  def _target
    type.underscore.sub(/^import_/, '')
  end

  # fake method for view
  def file_upload
    self.filename
  end

  # 1. load sheets, assign self.filename
  # 2. set field mapping for this upload
  # 3. reset imported, and, set other customized stuffs...
  def file_upload=(upload_field)
    logger.debug "upload_file, user_id: #{self.user_id}"
    _do = "upload"
    reset_imported
    self.filename = upload_field.original_filename
    ext = File.extname(base_part_of(self.filename).downcase)
    self.sheets = self.class.load_xls(upload_field, ext)
    if self.sheets && !self.sheets.empty?
      logger.debug "upload_file ok, filename:#{upload_field.original_filename}"
    end
    set_field_mapping
    on_upload
    return filename
  rescue => e
    logger.warn "exception: #{e.to_s}\n#{e.backtrace.join("\n")}"
    sheets = []
    logger.debug "file_upload failed, filename:#{upload_field.original_filename}"
    _do = "upload:fail"
    return nil
  end

  def on_upload
  end

  def validate_mapping
    if mapping.empty?
      errors.add :mapping, "no mapping fields found in upload file"
      return false
    else
      return true
    end
  end

  def validate_sheets
    ec = 0
    if !sheets || sheets.empty?
      self.errors[:file_upload] << "failed to open file: #{filename}"
      ec += 1
    end

    if !imported[:sheets] || imported[:sheets].empty?
      errors.add :sheets, "no valid sheet to import data"
      ec += 1

      imported[:bad_sheets].each do |sheet|
        fields = sheet[:fields]
        ignore = sheet[:ignore]
        missing = sheet[:missing]
        errors.add :sheets, "bad sheet: sheet(#{sheet[:id]}) `#{sheet[:name]}`:\n" +
          "fields: #{fields.to_s} ignore: #{ignore.to_s} missing: #{missing.to_s}"
        ec += 1
      end
    end
    return ec == 0
  end

  # finish the import task
  def import
    return if mapping.empty? || self._do != "import"

    failed = false
    sheets.each do |sheet|
      if sheet[:empty]
        logger.debug "skip empty sheet[#{sheet[:id]}]: #{sheet[:name]}"
        next
      end
      next if sheet[:empty]
      if !start_import?(sheet)
        logger.warn "failed to start import, id:#{id} sheet[#{sheet[:id]}]: #{sheet[:name]}"
        imported[:_fail] = [sheet[:name], 0]
        failed = true
        break
      end
      # get the mapping
      map = []
      sheet[:header].each do |field|
        map.push mapping[field]
      end

      row_index = 1
      sheet[:cells].each do |row|
        params = {}
        for i in 0..(map.size-1)
          to_field = map[i]
          if to_field && row[i] && (!row[i].kind_of?(String) || !row[i].empty?)
            # make a patch for roo, for string/integer fields
            # strip \.0+ for :string & :integer
            column_type = self.class.map_dict[:_types][to_field]
            if column_type == :string || column_type == :integer
              row[i] = row[i].to_s.sub(/\.0+$/, '')
            end

            # convert non-empty fields to rails style params
            to_field =~ /([A-Za-z_]+)\.([A-Za-z_]+)(\[(\d+)\])?/
              table, field, sub = [$1, $2, $4]
            params[table.to_sym] ||= {}
            if sub
              params[table.to_sym][field.to_sym] ||= []
              params[table.to_sym][field.to_sym][sub.to_i] ||= row[i]
            else
              params[table.to_sym][field.to_sym] = row[i]
            end
          end
        end
        if !import_row(params, row_index)
          imported[:_fail] = [sheet[:name], row_index]
          failed = true
          break
        else
          row_index += 1
        end
      end
      return if failed;
      if !end_import(sheet)
        imported[:_fail] = [sheet[:name], -1]
        break
      end
      self.imported[:rows] += row_index - 1
    end

    if failed
      # TODO: discard import, delete imported...
      discard_imported
    end
  end

  def start_import(sheet)
    logger.debug "start import sheet, id:#{sheet[:id]}, name:#{sheet[:name]}"
  end

  def import_row(params, row_index)
    logger.debug "import row, row:#{row_index}, params:#{params.to_s}"
    true
  end

  def end_import(sheet)
    true
  end

  def discard_imported
    counts = self.imported[:count]
    self.class.import_tables.each do |table, klass|
      count = counts[table]
      count = count.sum if count.kind_of?(Array)
      if imported[:_fail] || count > 0
        klass.delete_all(["import_id=?", self.id])
        logger.debug "discard import #{klass}, import_id:#{id} count:#{count}"
      end
    end
  end

  def import_local(local_file, comment="import local file")
    # step 1: upload
    self.comment = comment
    file = File.open(local_file)
    def file.original_filename
      self.path
    end
    self.file_upload = file
    self._do = "upload:local"
    save!

    # step 2. confirm & import
    self._do = "import"
    import
    save!
    self
  end

  private
  def base_part_of(file_name)
    File.basename(file_name) # .gsub(/[^\w._-]/, '')
  end

  def reset_imported
    imported[:count] = {}
    imported[:rows] = 0
    imported[:sheets] = []
    imported[:bad_sheets] = []
  end

  # check header, empty
  # set mappings
  def set_field_mapping
    self.mapping = {}
    self.imported[:sheets] = []
    self.imported[:bad_sheets] = []
    m = {}
    sheets.each do |sheet|
      # skip empty sheet
      next if sheet[:empty]

      ignore_fields = []
      ok_fields = []
      required_set = self.class.map_dict[:_required].dup
      # logger.debug "required_set: #{required_set.to_json}"
      dict = self.class.map_dict[:_mapping]
      col = "A"
      sheet[:header].each do |col_name|
        field = dict[col_name]
        if field
          ok_fields.push(col_name)
          required_set.delete field
          m[col_name] = field
        else
          # ignore_fields.push([col.dup, col_name])
          ignore_fields.push(col_name)
        end
        col.succ!
      end

      # check required fields, update sheets & bad_sheets
      ok_fields.uniq!
      if required_set.any?
        # logger.debug ">required_set: #{required_set.to_json}"
        imported[:bad_sheets].push({
          id: sheet[:id],
          name: sheet[:name],
          fields: ok_fields,
          ignore: ignore_fields,
          missing: required_set.values
        })
        # errors[:sheets] << "sheet #{sheet[:name]} missing required fields: #{required_set.values.join(', ')}"
      else
        imported[:sheets].push({
          id: sheet[:id],
          name: sheet[:name],
          fields: ok_fields,
          ignore: ignore_fields,
        })
      end
    end

    if imported[:bad_sheets].empty? && imported[:sheets].any?
      self.mapping = m
    end
    if imported[:sheets].empty?
      # errors[:sheets] << "no valid sheet to import"
      logger.warn "no valid sheet to import"
    end
  end

  def self.load_xls(file, ext)
    # logger.debug "load_xls, file:#{file}, ext:#{ext}"
    xls = self.open_spreadsheet(file, ext)
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
          thead: self.sheet_header(xls.last_column),
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
    # logger.debug "open_spreadsheet, ext:#{ext}"
    case ext
    when '.csv', 'csv'
      Roo::Csv.new(file.path)
    when '.xls', 'xls'
      Roo::Excel.new(file.path, nil, :ignore)
    when '.xlsx', 'xlsx'
      Roo::Excelx.new(file.path, nil, :ignore)
    else
      raise "Unknown uploaded type: #{file.original_filename}"
    end
  end

  def self.map_dict
    nil
  end

  # returns hash of name => [value, label]
  def self.auto_mapping
    self.map_dict[:_mapping]
  end

  def self.mapping_fields
    self.map_dict[:_fields]
  end

  def self.load_dict(table_name)
    class_dict = {
      _mapping: {},
      _fields: {},
      _required: {},
      _types: {},
    }

    dict = I18n.t("import_sheets.#{table_name}")
    field_mapping = {}
    fields = []
    types = {}

    # field_mapping: table.field => field_name
    dict.each do |table, map|
      if !table.to_s.start_with?("_")
        #klass = Kernel.const_get(table.to_s.classify)
        klass = table.to_s.classify.constantize
        map.each do |k, v|
          field = "#{table}.#{k}"
          unless types[field]
            column = k.to_s.gsub(/(\[\d+\])+/, '')
            types[field] = klass.columns_hash[column].type
          end
          field_mapping[v] = field
          fields.push ["#{table}.#{k}", v]
        end
      end
    end

    # add custom field names to mapping
    if dict[:_custom]
      dict[:_custom].each do |k, v|
        table, field = v.split(".")
        label = dict[table.to_sym][field.to_sym]
        field_mapping[k.to_s] = v
        fields.push [v, label]
      end
    end

    class_dict[:_mapping] = field_mapping
    class_dict[:_fields] = fields.uniq

    # if no specified, all fields are required
    r = dict[:_required] || field_mapping.invert
    class_dict[:_required] = {}
    r.each { |k,v| class_dict[:_required][k.to_s] = v }

    class_dict[:_types] = types
    class_dict
  end

  def self.inherited(child)
    child.instance_eval do
      def model_name
        ImportSheet.model_name
      end
    end
    super
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
      "价格带" => "merchandise.price_zone",
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

