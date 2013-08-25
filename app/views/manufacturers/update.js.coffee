  # replace the modified record
  id = <%= @manufacturer.id %>
  new_tr = "<%=j render partial: 'item', locals: { manufacturer: @manufacturer } %>"
  tr = $("#manufacturers-list tr[data-id=#{id}]")
  bgColor = tr.css("background-color")
  tr.replaceWith(new_tr)
  tr = $("#manufacturers-list tr[data-id=#{id}]")

<% if @manufacturer.errors.any? %>
  # show errors
<% else %>
  # highlight the modified record
  tr.css({'background-color': 'yellow'}).animate({'background-color': bgColor}, 1500)
<% end %>
