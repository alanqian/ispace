module StoresHelper
  def name_with_mark(store)
    if store.ref_store_id.nil?
      raw "#{store.name}<sup>?</sup>"
    elsif store.ref_store_id == store.id
      raw "#{store.name}<sup>*</sup>"
    else
      store.name
    end
  end
end
