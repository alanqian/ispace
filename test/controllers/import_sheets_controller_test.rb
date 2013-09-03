# encoding: utf-8
require 'test_helper'

class ImportSheetsControllerTest < ActionController::TestCase
  fixtures :import_sheets

  setup do
    @logger = Rails.logger
    @import_sheet = import_sheets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:import_sheets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should show import_sheet" do
    get :show, id: @import_sheet
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @import_sheet
    assert_response :success
  end

  test "should 3-step create,update import_sheet" do
    assert_difference('ImportSheet.count') do
      sheet_file = fixture_file_upload('files/test.xls','application/xls')
      post :create, import_sheet: {
        step: 1,
        user_id: 1,
        comment: "test upload",
        upload_sheet: sheet_file,
      }
    end
    @import_sheet = assigns(:import_sheet)
    assert_redirected_to import_sheet_path(@import_sheet)
    # create end

    # test "should update import_sheet" do
    step_2 = {
      step: 2,
      comment: "test upload",
      sel_sheets: ["0", ""],
      category_id: "牙膏"
    }
    step_3 = {
      step: 3,
      user_id: 1,
      mapping: {
        "产品标识"=>"product.code", "名称"=>"product.name", "宽度"=>"product.width",
        "高度"=>"product.height", "深度"=>"product.depth", "供应商"=>"supplier.name",
        "大小"=>"product.size_name", "品牌"=>"brand.name", "利润"=>"merchandise.profit",
        "销售速度"=>"merchandise.volume", "销售额"=>"merchandise.value",
        "价格"=>"merchandise.price", "价格带"=>"product.price_level",
        "新品"=>"product.new_product"
      }
    }

    patch :update, id: @import_sheet, import_sheet: step_2
    assert_redirected_to import_sheet_path(assigns(:import_sheet))

    patch :update, id: @import_sheet, import_sheet: step_3
    assert_redirected_to import_sheet_path(assigns(:import_sheet))
  end

  test "should destroy import_sheet" do
    assert_difference('ImportSheet.count', -1) do
      delete :destroy, id: @import_sheet
    end

    assert_redirected_to import_sheets_path
  end
end
