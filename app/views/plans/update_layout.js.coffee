<% if @plan.errors.empty? %>
  window.planEditor.setSaved(<%= @plan.version %>)
<% else %>
  window.planEditor.showServerError("<%= @error %>")
<% end %>
