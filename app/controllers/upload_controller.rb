class UploadController < ApplicationController
  def get
    @import = Import.new
  end

  def show
    @import = Import.find(params[:id])
  end

  def save
    @import = Import.new(sheet_params)
    if @import.save
      redirect_to(action: 'show', id: @import.id)
    else
      redirect_to(action: 'get')
    end
  end

  private
    def sheet_params
      params.require(:import).permit(:upload_sheet, :store_id, :user_id)
    end
end
