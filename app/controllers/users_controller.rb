class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  def show
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        logger.debug user_params
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
        format.js { set_user_update_js }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def index
    @users = User.all
    render "index", locals: { user_new: User.new }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_user_update_js
    @user.reload
  end

  def user_params
    params.require(:user).permit(:username, :employee_id, :email, :telephone, :password, :password_confirmation)
  end
end
