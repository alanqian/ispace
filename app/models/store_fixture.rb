class StoreFixture < ActiveRecord::Base
  belongs_to :store
  belongs_to :fixture
  belongs_to :category
  serialize :layers, Array
  validates :store_id, presence: true
  validates :fixture_id, presence: true
  validates :category_id, presence: true
  validates :code, presence: true
  validates :category_name, presence: true

  attr_accessor :category_name

  def version
    updated_at.to_i
  end

  def self.verify_store_fixture?(store_id, category_id)
    self.exists?(store_id: store_id, category_id: category_id)
  end

  def self.store_fixture(store_id, category_id)
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
