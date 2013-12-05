class StoreFixture < ActiveRecord::Base
  belongs_to :store
  belongs_to :fixture
  belongs_to :category
  serialize :parts, Hash
  validates :store_id, presence: true
  validates :fixture_id, presence: true
  validates :category_id, presence: true
  validates :category_name, presence: true
  validates :code, presence: true
  before_save :update_parts_this

  attr_accessor :category_name
  attr_accessor :use_part_fixture
  attr_accessor :parts_start
  attr_accessor :parts_run
  attr_accessor :show_up_dir

  def use_part_fixture
    parts.any?
  end

  def parts_start
    parts[:start]
  end

  def parts_run
    parts[:run]
  end

  def parts_prev
    parts[:prev]
  end

  def parts_next
    parts[:next]
  end

  def update_parts_this
    logger.debug "update_parts_this: #{self.to_json}"
    if @use_part_fixture && @parts_start && @parts_run
      self.parts = {
        start: @parts_start,
        run: @parts_run,
      }
    else
      self.parts = {}
    end
  end

  def version
    updated_at.to_i
  end

  def self.verify_store_fixture?(store_id, category_id)
    self.exists?(store_id: store_id, category_id: category_id)
  end

  def self.store_fixture(store_id, category_id)
    # TODO: category_id?, first?
    self.where(["store_id=? and category_id=?", store_id, category_id]).first
  end

  def self.upsert_fixture(store_id, category_id, fixture_id)
    code = Digest::MD5.hexdigest(Time.now.to_s)
    sf = self.create({
      code: code,
      store_id: store_id,
      category_id: category_id,
      category_name: "foo",
      fixture_id: fixture_id
    })
    logger.info "create store_fixture, fixture:#{fixture_id} store_id:#{store_id} category_id:#{category_id}"
  rescue ActiveRecord::RecordNotUnique => e
    # handle duplicate entry
    self.where("store_id = ? AND category_id = ?", store_id, category_id).
      update_all(fixture_id: fixture_id)
    logger.info "update store_fixture, fixture:#{fixture_id} store_id:#{store_id} category_id:#{category_id}"
  end
end
