require 'test_helper'

class ImportSheetsControllerTest < ActionController::TestCase
  setup do
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

  test "should create import_sheet" do
    assert_difference('ImportSheet.count') do
      post :create, import_sheet: { comment: @import_sheet.comment, data: @import_sheet.data, ext: @import_sheet.ext, filename: @import_sheet.filename, imported: @import_sheet.imported, step: @import_sheet.step, store_id: @import_sheet.store_id, user_id: @import_sheet.user_id }
    end

    assert_redirected_to import_sheet_path(assigns(:import_sheet))
  end

  test "should show import_sheet" do
    get :show, id: @import_sheet
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @import_sheet
    assert_response :success
  end

  test "should update import_sheet" do
    patch :update, id: @import_sheet, import_sheet: { comment: @import_sheet.comment, data: @import_sheet.data, ext: @import_sheet.ext, filename: @import_sheet.filename, imported: @import_sheet.imported, step: @import_sheet.step, store_id: @import_sheet.store_id, user_id: @import_sheet.user_id }
    assert_redirected_to import_sheet_path(assigns(:import_sheet))
  end

  test "should destroy import_sheet" do
    assert_difference('ImportSheet.count', -1) do
      delete :destroy, id: @import_sheet
    end

    assert_redirected_to import_sheets_path
  end
end
