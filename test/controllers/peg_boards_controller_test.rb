require 'test_helper'

class PegBoardsControllerTest < ActionController::TestCase
  setup do
    @peg_board = peg_boards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:peg_boards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create peg_board" do
    assert_difference('PegBoard.count') do
      post :create, peg_board: { bay_id: @peg_board.bay_id, color: @peg_board.color, depth: @peg_board.depth, height: @peg_board.height, horz_space: @peg_board.horz_space, horz_start: @peg_board.horz_start, level: @peg_board.level, name: @peg_board.name, notch_num: @peg_board.notch_num, vert_space: @peg_board.vert_space, vert_start: @peg_board.vert_start }
    end

    assert_redirected_to peg_board_path(assigns(:peg_board))
  end

  test "should show peg_board" do
    get :show, id: @peg_board
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @peg_board
    assert_response :success
  end

  test "should update peg_board" do
    patch :update, id: @peg_board, peg_board: { bay_id: @peg_board.bay_id, color: @peg_board.color, depth: @peg_board.depth, height: @peg_board.height, horz_space: @peg_board.horz_space, horz_start: @peg_board.horz_start, level: @peg_board.level, name: @peg_board.name, notch_num: @peg_board.notch_num, vert_space: @peg_board.vert_space, vert_start: @peg_board.vert_start }
    assert_redirected_to peg_board_path(assigns(:peg_board))
  end

  test "should destroy peg_board" do
    assert_difference('PegBoard.count', -1) do
      delete :destroy, id: @peg_board
    end

    assert_redirected_to peg_boards_path
  end
end
