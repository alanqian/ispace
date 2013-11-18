class PagesController < ApplicationController
  before_action :authenticate_user!
  def index
    if current_user.admin?
      redirect_to stores_path
    elsif current_user.designer?
      redirect_to plan_sets_path
    else current_user.salesman?
      redirect_to plan_sets_path(_do: :recent)
    end
  end
end
