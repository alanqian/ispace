require 'test_helper'


class ImportSheetTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess
  fixtures :import_sheets

  test "upload spreadsheet files: csv,xls,xlsx" do
    ok = [["test.xls", 3], ["test.csv", 1], ["test.xlsx", 1]]
    bad = ['test.bad']

    ok.each do |filename, count|
      import_sheet = upload_file(filename)
      Rails.logger.debug "test upload ok, file:#{filename}"
      assert import_sheet.step == 2,
        "should to step 2, file:#{filename}"
      assert import_sheet.sheets.count == count,
        "sheet count error, file:#{filename} count:#{import_sheet.sheets.count} should:#{count}"
      Rails.logger.debug import_sheet.sheets
    end
    bad.each do |filename|
      import_sheet = upload_file(filename)
      Rails.logger.debug "test upload bad, file:#{filename}"
      assert import_sheet.step == 1,
        "should stay at step 1, file:#{filename}"
      Rails.logger.debug import_sheet.errors
    end
  end

  def upload_file(filename)
    import_sheet = ImportSheet.new(step: 1)
    import_sheet.store_id = 1
    import_sheet.user_id = 1
    file = fixture_file_upload("files/#{filename}", nil, true)
    assert file != nil
    import_sheet.upload_sheet = file
    return import_sheet
  end
end
