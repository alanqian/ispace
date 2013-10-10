<% if @plan.errors.empty? %>
  window.planEditor.setSaved(<%= @version %>)
<% else %>
  window.planEditor.showServerError("<%= @error %>")
<% end %>
