class Import < ActiveRecord::Base

  def upload_sheet=(sheet_field)
    self.filename = base_part_of(sheet_field.original_filename)
    self.ext = File.extname(self.filename)
    self.step = 1

    # save to local file system, as backup
    logger.debug "upload_sheet, user_id: #{self.user_id}"
    FileUtils.mkdir_p(File.dirname(local_file))
    File.open(local_file, 'wb') { |f| f.write sheet_field.read }
  end

  def local_file
    Ispace::Application.config.sheet_dir + self.filename
  end

  def base_part_of(file_name)
    File.basename(file_name) # .gsub(/[^\w._-]/, '')
  end

end
