require 'zip'

class Product < ActiveRecord::Base
  include RandomColor
  include UnderCategory
  HASH_SIZE = 257

  belongs_to :category
  self.primary_key = "code"

  scope :on_shelf, ->(grade = 'Q') { where(["grade <= ?", grade]) }
  attr_accessor :image_upload
  before_save :check_upload

  # return image filename if success, otherwise nil
  def update_image_file(basename, ext)
    return nil if ext != ".jpg"
    code = File.basename(basename, ext)
    product = self.class.find_by(code: code)
    if product != nil
      subdir = code.to_i % HASH_SIZE
      filename = "#{subdir}/#{basename}"
      product.update_column(:image_file, filename)
      logger.info "image_upload ok, product:#{code}"
      filename
    else
      logger.warn "image_upload failed, cannot find product, code:#{code}"
      nil
    end
  end

  def process_upload
    filename = image_upload.original_filename
    basename = File.basename(filename).downcase
    ext = File.extname(basename)
    self.image_file = [] # indicates image_upload ok
    logger.debug "upload_file, file:#{filename} size:#{image_upload.size} basename:#{basename} ext: #{ext}"
    case ext
    when '.jpg'
      # find product, if found, set it and move to proper dictectory
      filename = update_image_file(basename, ext)
      if filename != nil
        File.open("#{Rails.root}/public/images/products/#{filename}", "wb") do |f|
          f.write(image_upload.read)
        end
        self.image_file.push filename
      end
    when '.zip'
      # unzip it, if found, set it and move to proper dictectory
      Zip.on_exists_proc = true
      Zip::File.open(image_upload.tempfile) do |zipfile|
        zipfile.each do |zipf|
          logger.debug "zipfile, zipf:#{zipf} #{zipf.class}"
          basename = File.basename(zipf.name).downcase
          ext = File.extname(basename)
          filename = update_image_file(basename, ext)
          if filename != nil
            zipf.extract("#{Rails.root}/public/images/products/#{filename}")
            #File.open("#{Rails.root}/public/images/products/#{filename}", "wb") do |f|
            #  f.write zipfile.file.read(zipf.filepath)
            #end
            self.image_file.push filename
          end
        end
      end
    else
      logger.warn "unknown products image file, filename:#{filename}"
    end
  end

  # don't create when upload image file
  def check_upload
    _do != :image_upload
  end

  def self.version
    last_update_time = self.maximum(:updated_at) || 0
    last_update_time.to_i
  end

  def display_name
    "#{name} #{size_name} #{case_pack_name}"
  end

  def to_opt
    Option.new(code, display_name)
  end
end
