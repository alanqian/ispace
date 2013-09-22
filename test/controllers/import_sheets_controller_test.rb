# encoding: utf-8
require 'test_helper'

class ImportSheetsControllerTest < ActionController::TestCase
  fixtures :import_sheets, :categories # for import product

  setup do
    @logger = Rails.logger
    @import_sheet = import_sheets(:one)
    @types = [nil, "sale", "product", "category", "store"]
  end

  test "a. should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:import_sheets)

    get :index, _t: 'sale'
    assert_response :success
    assert_not_nil assigns(:import_sheets)

    get :index, _t: 'sale', _designer:1
    assert_response :success
    assert_not_nil assigns(:import_sheets)

    get :index, _t: 'product'
    assert_response :success
    assert_not_nil assigns(:import_sheets)
  end

  test "b. should get new" do
    @types.each do |t|
      get :new, _t: t
      assert_response :success
    end
  end

  test "should show import_sheet" do
    sheets = ImportSheet.all
    sheets.each do |sh|
      @logger.debug "test show #{sh}"
      get :show, id: sh
      assert_response :success
    end
  end

  test "should get edit" do
    sheets = ImportSheet.all
    sheets.each do |sh|
      @logger.debug "test edit #{sh}"
      get :edit, id: sh
      assert_response :success
    end
  end

  test "should destroy import_sheet" do
    assert_difference('ImportSheet.count', -1) do
      delete :destroy, id: @import_sheet
    end
    assert_redirected_to import_sheets_path
  end

  # upload/import
  test "should create/update import_sheet" do
    ok = [
      ["category.xls", "ImportCategory", Category],
      ["product.xls", "ImportProduct", Product],
      ["sale.xls", "ImportSale", Sale],
      ["store.xls", "ImportStore", Store],
    ]
    ok.each do |f, type, klass|
      @logger.debug "test upload #{f}"
      upload = fixture_file_upload("files/#{f}",'application/xls')
      assert_difference('ImportSheet.count') do
        post :create, import_sheet: {
          store_id: 1,
          user_id: 1,
          type: type,
          _do: "upload",
          comment: "ImportXXX",
          file_upload: upload,
        }
        @import_sheet = assigns(:import_sheet)
        assert_redirected_to edit_import_sheet_path(@import_sheet)
      end

      count = klass.count
      patch :update, id: @import_sheet, commit: "导入", import_sheet: {
        comment: "import it!",
        _do: "import"
      }
      assert_redirected_to import_sheet_path(assigns(:import_sheet))
      diff = klass.count - count
      @logger.debug "#{type} imported: #{diff}"
      assert diff >= 2, "at least import two records"
    end
  end

  test "x: should 3-step create,update import_sheet" do
    skip "skip deprecated test case"
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
        "价格"=>"merchandise.price", "价格带"=>"product.price_zone",
        "新品"=>"product.new_product"
      }
    }

    patch :update, id: @import_sheet, import_sheet: step_2
    assert_redirected_to import_sheet_path(assigns(:import_sheet))

    patch :update, id: @import_sheet, import_sheet: step_3
    assert_redirected_to import_sheet_path(assigns(:import_sheet))
  end
end
