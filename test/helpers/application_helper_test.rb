require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "data_th_list" do
    logger.debug "testing data_th_list"
    ths = data_th_list(:product,
      [:select_all, "products[]"],
      [:select_all, "products[]", class: "test-select-all"],
      [:code],
      [:code, input: false],
      [:code, input: false, sort: false, search: false ],
      [:code, input: false, show: false ],
      ["string-value", input: "products[name]"],
      ["last-pure-string-value"]
    )
    logger.debug "data_th_list output: >>\n#{ths}"
  end
end
