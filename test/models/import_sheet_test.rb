require 'test_helper'


class ImportSheetTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    @logger = Rails.logger
    @import_sheet = nil
  end

  def upload_sheet(filename)
    file = fixture_file_upload("files/#{filename}", nil, true)
    assert file != nil
    @import_sheet.file_upload = file
    @import_sheet._do = "upload"
    @import_sheet.comment = "test upload"
    @import_sheet.valid?
    return @import_sheet
  end

  def dump
    @logger.debug ">>sheets: #{@import_sheet.sheets.to_s}"
    @logger.debug ">>mapping: #{@import_sheet.mapping.to_s}"
    @logger.debug ">>imported: #{@import_sheet.imported.to_s}"
    @logger.debug ">>upload: #{@import_sheet.filename.to_s}"
    @logger.debug ">>errors: #{@import_sheet.errors.to_json}"
  end
end
