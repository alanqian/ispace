root = exports ? this

root.foo = () ->
  console.log "foo"

$ ->
  console.log "application common loaded"
  $("#menubar").menu()

