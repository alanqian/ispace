module ApplicationHelper
  def tm(model)
    model ||= controller_name.classify.downcase
    return I18n.t "activerecord.attributes.#{model.downcase}"
  end

  def tf(field, object_sym=nil)
    if object_sym
      model = object_sym.to_s
    else
      model = controller_name.classify.downcase
    end
    prefixs = ["activerecord.attributes.#{model}", "simple_form.labels.defaults", "dict"]
    prefixs.each do |prefix|
      s = I18n.t("#{prefix}.#{field}", default: '')
      return s unless s.empty?
    end
    # check field: xxx_id
    if field =~ /_id$/
      f = field.to_s.sub(/_id$/, "")
      prefixs.each do |prefix|
        s = I18n.t("#{prefix}.#{f}", default: '')
        return s unless s.empty?
      end
    end
    return I18n.t("#{prefixs[0]}.#{field}")
  end

  def simple_title(_do)
    item = _do || "defaults"
    I18n.t("simple_form.titles.#{controller_name.singularize}.#{item}")
  end

  def content_for_title(_do)
    content_for :title, simple_title(_do)
  end

  def simple_confirm(action)
    I18n.t("simple_form.confirms.#{controller_name.singularize}.#{action}")
  end

  def simple_label(action_or_field)
    label(controller_name.singularize, action_or_field)
    #translate("labels.#{action_or_field}")
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

  def humanize(secs)
    return "NOW" if secs == 0
    names = [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        n == 0 ? "" : "#{n.to_i}#{I18n.t("time.#{name}")}"
      end
    }.compact.last(2)
    if names.first == ""
      names.shift
    end
    names.reverse.join(I18n.t("time.joiner"))
  end

  def dt_ago(datetime)
    return "" if datetime.nil?
    now = Time.now()

    today = now.beginning_of_day
    days_ago = ((today - datetime.beginning_of_day) / 1.day).to_i
    days = [
      now.beginning_of_week(:sunday),
      now.beginning_of_week(:sunday).ago(7.days),
      now.beginning_of_month,
      now.beginning_of_month.ago(1.days).beginning_of_month,
    ].map { |day| ((today - day) / 1.day).to_i }
    # Rails.logger.debug "#{days_ago} #{days.to_s}"

    case days_ago
    when 0..2
      # today, yesterday, the day before yesterday
      formats = [:today, :yesterday, :the_day_before_yesterday]
      I18n.l datetime, :format => formats[days_ago]
    when 3..days[0] # days_in_this_week
      # in this week, weekday hh:mm
      I18n.l datetime, :format => :this_week
    when (days[0] + 1)..days[1] # days_in_prev_week
      I18n.l datetime, :format => :last_week
    when (days[1] + 1)..days[2] # days_in_this_month
      I18n.l datetime, :format => :this_month
    when (days[2] + 1)..days[3] # days_in_prev_month
      I18n.l datetime, :format => :last_month
    else
      # yy-mm-dd
      I18n.l datetime, :format => :date_only
    end
  end

  def select_one_check(id, sel_target, opts = {})
    opts ||= {}
    opts[:onclick] ||= "javascript: onClickSelectOne(event, this);"
    opts[:data] ||= {}
    opts[:id] ||= "#{sel_target.gsub(/s?\[\]/, "_")}#{id}"
    opts[:data][:select_all] ||= "#SELECT_ALL"
    if opts.has_key?(:class)
      opts[:class] = "select-one #{opts[:class]}"
    else
      opts[:class] = "select-one"
    end
    check_box_tag(sel_target, id, false, opts)
  end

  def select_all_check(sel_target, opts = {})
    opts ||= {}
    opts[:onclick] ||= "javascript: onClickSelectAll(event, this);"
    opts[:data] ||= {}
    opts[:data][:target] ||= sel_target
    if opts.has_key?(:class)
      opts[:class] = "select-all boolean #{opts[:class]}"
    else
      opts[:class] = "select-all boolean"
    end
    check_box = check_box_tag(:SELECT_ALL, "1", false, opts)
    hint = content_tag("span", "", class: "hint")
    if opts.has_key?(:label)
      opts.delete(:onclick)
      label_text = opts.delete(:label)
      opts[:for] = "SELECT_ALL"
      label = label_tag "select-all", label_text, opts
    else
      label = ""
    end
    check_box + label + hint
  end

  # data_array syntax:
  #   :field|value, { input:false, sort:false show:false }
  # eg:
  #   :select_all, "products[]", ...
  #   :field
  #   :field, input:false|name, search:false, sort:false|a|d, show:false, ...
  #    value
  #    value, input:false|name, search:false, sort:false|a|d, show:false, ...
  #
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
  def data_th_list(object_sym, *data_array)
    object = object_sym.to_s.downcase
    ths = []
    data_array.each do |col|
      if col.is_a?(Array)
        # logger.debug "data col: #{col}"
        # w/ opts
        field = col.shift
        if field == :select_all
          sel_target, sel_opts = col
          sel_opts ||= {}
          opts = { no_input: "1", no_sort: "1", no_search: "1"}
          content = select_all_check(sel_target, sel_opts)
        else
          if field.is_a?(Symbol)
            opt = col.shift || {}
            opts = { input: "#{object}[#{field}]" }.merge(opt)
            content = tf(field, object_sym)
          else
            opts = col.shift || {}
            content = field
          end
          # normalize opts: input:, sort:, search:, show:
          # change :false to no_xxx
          [:input, :sort, :search, :show].each do |k|
            if opts.has_key?(k)
              v = opts[k]
              if v.kind_of?(FalseClass)
                opts.delete(k)
                opts["no_#{k}".to_sym] = 1
              end
            end
          end
        end
      else # scalar, w/o opts
        field = col
        if col.is_a?(Symbol)
          # :field => w/ default input, sort, search
          opts = { input: "#{object}[#{field}]" }
          content = tf(field, object_sym)
        else
          # input:nil, w/ default sort, search
          opts = {}
          content = col.to_s
        end
      end
      [:input,:no_input, :sort,:no_sort, :search,:no_search, :show,:no_show].each do |k|
        if opts.has_key?(k)
          v = opts.delete(k)
          opts[:data] ||= {}
          opts[:data][k] = v
        end
      end
      ths.push content_tag(:th, content, opts)
    end
    raw(ths.join("\n"))
  end

  def up_level(value, sep=".")
    r = value.rindex(sep)
    r == nil ? value : value[0..r-1]
  end

  # data_array syntax:
  #   [:select_one, :id-field, "sel-group"],
  #   [:field, collection: coll],
  #   [:field, content-value],
  #   :field,
  #   content-value,
  def data_td_list(object, *data_array)
    tds = []
    data_array.each do |col|
      opts = nil
      if col.is_a?(Array)
        # [:select_one, :code, "products[]"],
        # [:color, color_tag(product.color)],
        # [:brand_id, collection: brands_hash],
        t = col.shift
        if t == :select_one
          id, sel_target = col.shift(2)
          # test if it's a field?
          id = object.send(id) if id.is_a?(Symbol)
          content = select_one_check(id, sel_target)
          opts ||= {}
          opts[:align] ||= "center"
        else
          field = t
          val = field.is_a?(Symbol) ? object.send(field) : field
          opts = { data: {val: val}}
          t = col.shift
          if t.is_a?(Hash)
            coll = t[:collection]
            content = coll[val]
          else
            content = t.to_s
          end
        end
      elsif col.is_a?(Symbol)
        # :name,
        field = col
        content = object.send(field)
      else
        # simply pure value
        content = col
      end
      tds.push content_tag(:td, content, opts)
    end
    raw(tds.join("\n"))
  end

  def flash_contents
    alert_types = [:error, :info, :success, :warning]

    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = :success if type == :notice
      type = :error   if type == :alert
      next unless alert_types.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                           msg.html_safe, :class => "alert fade in alert-#{type}")
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end

  def bay_types(types)
    types.map { |t| I18n.t("activerecord.models.#{t}") }.join("+")
  end

  # categories, from plain sorted ActiveRecord::Relation to list of:
  #  name[3], code[3], show[3]
  def hier_categories(categories)
    name = Array.new(3, "")
    code = Array.new(3, "")
    show = Array.new(3, false)
    prev_level = -1
    list = []
    prev_code = Array.new(3, nil)
    tmp = categories.dup.push(OpenStruct.new({code: "xx", name:"xx"}))
    tmp.each do |cat|
      level = (cat.code.length - 1) / 2
      if level <= prev_level
        # back to previous level, output the row, then empty it
        if prev_level < 2
          name.fill("", (prev_level + 1)..2)
          code.fill("", (prev_level + 1)..2)
        end
        0.upto(2) { |i| show[i] = (code[i] != prev_code[i]) }
        prev_code = code.dup
        list.push(OpenStruct.new({
          name: name.dup,
          code: prev_code,
          show: show.dup
        }))
        prev_level = -1
      end
      code[level] = cat.code
      name[level] = cat.name
      prev_level = level
    end
    list
  end

  # define category_menu for tree-input
  def category_menu(cmd = "select-category")
    tree_input_menu(cmd, Category.tree.to_json)
  end

  def tree_input_menu(cmd, tree)
    content_tag :div, "", class: "ui-tree-input-menu hide", data: {
      cmd: cmd, tree: tree }
  end
end
