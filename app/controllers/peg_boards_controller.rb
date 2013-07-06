class PegBoardsController < ApplicationController
  before_action :set_peg_board, only: [:show, :edit, :update, :destroy]

  # GET /peg_boards
  # GET /peg_boards.json
  def index
    @peg_boards = PegBoard.all
  end

  # GET /peg_boards/1
  # GET /peg_boards/1.json
  def show
  end

  # GET /peg_boards/new
  def new
    @peg_board = PegBoard.new
  end

  # GET /peg_boards/1/edit
  def edit
  end

  # POST /peg_boards
  # POST /peg_boards.json
  def create
    @peg_board = PegBoard.new(peg_board_params)

    respond_to do |format|
      if @peg_board.save
        format.html { redirect_to @peg_board, notice: 'Peg board was successfully created.' }
        format.json { render action: 'show', status: :created, location: @peg_board }
      else
        format.html { render action: 'new' }
        format.json { render json: @peg_board.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /peg_boards/1
  # PATCH/PUT /peg_boards/1.json
  def update
    respond_to do |format|
      if @peg_board.update(peg_board_params)
        format.html { redirect_to @peg_board, notice: 'Peg board was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @peg_board.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /peg_boards/1
  # DELETE /peg_boards/1.json
  def destroy
    @peg_board.destroy
    respond_to do |format|
      format.html { redirect_to peg_boards_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_peg_board
      @peg_board = PegBoard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def peg_board_params
      params.require(:peg_board).permit(:bay_id, :level, :name, :height, :depth, :vert_space, :horz_space, :vert_start, :horz_start, :notch_num, :color)
    end
end
