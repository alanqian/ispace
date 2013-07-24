root = exports ? this

root.foo = () ->
  console.log "foo"

root.setSheetUI = () ->
  $("table.resizable").colResizable({
    liveDrag: true,
    gripInnerHtml: "<div class='grip'></div>",
    draggingClass: "dragging",
    onResize: null})

  $("div.tabs").tabs(
    activate: (event, ui) ->
      console.log "activate:", ui.newPanel.selector
      window.location.hash = ui.newPanel.selector
  )
  if $("div.tabs-bottom").length > 0
    console.log "fixing tabs in bottom"
    # fix the classes
    $("div.tabs-bottom ul").removeClass("ui-hidden")
    $( ".tabs-bottom .ui-tabs-nav, .tabs-bottom .ui-tabs-nav > *" )
      .removeClass( "ui-corner-all ui-corner-top" )
      .addClass( "ui-corner-bottom" )
    # move the nav to the bottom
    $( ".tabs-bottom .ui-tabs-nav" ).appendTo( ".tabs-bottom" )

  # set bgcolor of first column of a spreadsheet
  bgcolor = $(".ui-widget-header").css("background-color")
  $("td:first", $("table.grid-control tbody tr")).css("background-color",
    bgcolor).css("text-align", "center")


$ ->
  console.log "loading common components..."
  # $.ajaxSettings.dataType = "json"
  $("#menubar").menu({ position: { my: "left top", at: "left-1 top+35" } })
  $("table.dataTable").dataTable({
    "aaSorting": [[ 4, "desc" ]],
    "bJQueryUI": true,
    "aLengthMenu": [[5, 10, 15, 25, 50, -1], [5, 10, 15, 25, 50, "All"]],
    "iDisplayLength": 10,
    'bLengthChange': false,
    #"sScrollY": calcDataTableHeight(), don't use, it will split to two tables
    #"sPaginationType": "full_numbers",
    # length-change, info, pagination, filtering input
    # dataTables_length
    # dataTables_info
    # dataTables_paginate
    # dataTables_filter
    "sDom": '<"top"ipf>rt<"clear">',
    "oLanguage": {
        "sProcessing":   "处理中...",
        "sLengthMenu":   "每页显示 _MENU_ 条，",
        "sZeroRecords":  "没有匹配结果",
        "sInfo":         "_START_ - _END_，共 _TOTAL_ 条",
        "sInfoEmpty":    "无结果，请重新搜索",
        "sInfoFiltered": "&#47; _MAX_ 条",
        "sInfoPostFix":  "",
        "sSearch":       "搜索:",
        "sUrl":          "",
        "oPaginate": {
            "sFirst":    "首页",
            "sPrevious": "上页",
            "sNext":     "下页",
            "sLast":     "末页"
        }
    }})

  # resizable, tabs, tabs-bottom, ...
  setSheetUI()
  $("div.accordion").accordion()
  console.log "common components loaded"

