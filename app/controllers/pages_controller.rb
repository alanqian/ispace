class PagesController < ActionController::Base
  before_action :authenticate_user!
  def index
    if current_user.admin?
      redirect_to stores_path
    elsif current_user.designer?
      redirect_to plan_sets_path
    end
  end
end
