class StoreFixture < ActiveRecord::Base
  belongs_to :store
  belongs_to :fixture
  belongs_to :category

  def self.verify_store_fixture?(store_id, category_id)
    self.exists?(store_id: store_id, category_id: category_id)
  end

  def self.store_fixture(store_id, category_id)
    self.where(["store_id=? and category_id=?", store_id, category_id]).first
  end

  def self.upsert_fixture(store_id, category_id, fixture_id)
    code = Digest::MD5.hexdigest(Time.now.to_s)
    self.create({
      code: code,
      store_id: store_id,
      category_id: category_id,
      fixture_id: fixture_id
    })
  rescue ActiveRecord::RecordNotUnique => e
    # handle duplicate entry
    self.where("store_id = ? AND category_id = ?", store_id, category_id).
      update_all(fixture_id: fixture_id)
  end
end
