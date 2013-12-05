<% if @plan.errors.empty? %>
  # update ok
  # TODO: something after updated successfully
<% else %>
  # update failed
  window.planEditor.showServerError("<%= @error %>")
<% end %>
