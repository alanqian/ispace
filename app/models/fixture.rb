class Fixture < ActiveRecord::Base
  has_many :fixture_items, dependent: :destroy
  accepts_nested_attributes_for :fixture_items, allow_destroy: true

  def deep_copy(store_id, uid)
    # copy self
    new_fixture = self.dup # shallow copy
    new_fixture.name += "(copy)"
    new_fixture.store_id = store_id
    new_fixture.user_id = user_id
    new_fixture.save!

    # copy associations
    copy_assoc_to(new_fixture, :fixture_items)

    new_fixture
  end

  private
    def copy_assoc_to(new_fixture, assoc_sym)
      self.send(assoc_sym).each do |row|
        new_row = row.dup # shallow copy
        new_fixture.send(assoc_sym) << new_row
      end
    end
end
