module ApplicationHelper
  def tm(model)
    model ||= controller_name.classify.downcase
    return I18n.t "activerecord.attributes.#{model.downcase}"
  end

  def tf(field)
    model = controller_name.classify.downcase
    prefixs = ["activerecord.attributes.#{model}", "dict"]
    prefixs.each do |prefix|
      s = I18n.t("#{prefix}.#{field}", default: '')
      return s unless s.empty?
    end
    return I18n.t("#{prefixs[0]}.#{field}")
  end

  def color_tag(color)
    content_tag(:span, raw("&nbsp;"), class: "colorbox", style: "background-color: #{color};")
  end

  def rel_hash(rel_array, key, value)
    return Hash[* rel_array.map{|r| [r[key], r[value]]}.flatten]
  end

  def rel3_hash(rel3_array, f1, f2, f3)
    hash = {}
    rel3_array.each do |r|
      hash[r[f1]] ||= {}
      hash[r[f1]][r[f2]] = r[f3]
    end
    hash
  end

  def select_one_check(id, sel_target, opts = {})
    opts[:onclick] ||= "javascript: onClickSelectOne(event, this);"
    opts[:data] ||= {}
    opts[:id] ||= "#{sel_target.gsub(/s?\[\]/, "_")}#{id}"
    opts[:data][:select_all] ||= "#SELECT_ALL"
    check_box_tag(sel_target, id, false, opts)
  end

  def select_all_check(sel_target, opts = {})
    opts[:onclick] ||= "javascript: onClickSelectAll(event, this);"
    opts[:data] ||= {}
    opts[:data][:target] ||= sel_target
    check_box_tag(:SELECT_ALL, "1", false, opts)
  end

  # :field                w/ default input, sort, search
  #       <th data-input="product[code]"><%=tf :code %></th>
  #  value                input:nil, w/ default sort, search
  #       <th data-noinput="1" data-no-sort="1" data-no-search="1"><%=tf "status" %></th>
  # :select_all, target, opts   no-input, no-sort, no-search
  #       <th data-noinput="1" data-no-sort="1"><%= select_all_check 'products[]', opts %></th>
  # :field,  input:?, sort:"d|a|false", search:false
  #       see :field
  #  value,  input:?, sort:, search:, show:
  #       see :field
  def data_th_list(object_sym, data_array)
    object = object_sym.to_s.downcase
    data_array.each do |col|
      if col.is_a?(Array)
        # w/ opts
        field = col[0]
        opts = col[1]
        if col == :select_all
          opts = { no_sort: "1", no_search: "1"}
        end
      else
        # w/o opts
        field = col
        if col.is_a?(Symbol)
          opts = { input: ""}
        else
          opts = { no_sort: "1", no_search: "1"}
        end
      end
    end
  end
end
