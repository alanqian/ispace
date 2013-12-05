require 'test_helper'
require File.dirname(__FILE__) + '/import_sheet_test'

class ImportStoreTest < ImportSheetTest

  setup do
    @import_sheet = ImportStore.new(store_id: 1, user_id: 1)
    @ok = ["store.xls"]
    @bad = ['bad_upload.file', "missing_field.xlsx"]
  end

  test "a. upload xls file: xls,xlsx" do
    @ok.each do |filename|
      @logger.debug "test upload ok file:#{filename}"

      upload_sheet(filename)
      dump
      assert @import_sheet.errors.empty?, "upload ok file #{filename} failed"
    end

    @bad.each do |filename|
      @logger.debug "test upload bad file:#{filename}"
      @import_sheet.errors.clear

      upload_sheet(filename)

      assert @import_sheet.imported[:sheets].empty?, "upload bad file #{filename}"
      dump
    end
  end

  test "b. import xls file" do
    @ok.each do |filename|
      @logger.debug "test import ok file:#{filename}"

      upload_sheet(filename)
      @import_sheet._do = "import"
      @import_sheet.import

      dump
      assert @import_sheet.errors.empty?, "import ok file #{filename} failed"

      count = @import_sheet.imported[:count]
      rows = @import_sheet.imported[:rows]
      count.each do |k, cnt|
        assert cnt > 0 && cnt <= rows, "import #{k} count <= rows"
      end

      ok_sheets = @import_sheet.imported[:sheets]
      assert ok_sheets.any?, "import at least a valid sheet"
      bad_sheets = @import_sheet.imported[:bad_sheets]
      assert bad_sheets.empty?, "no bad sheet"
    end
  end
end
