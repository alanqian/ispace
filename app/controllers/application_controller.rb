class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :layout_by_resource
  load_and_authorize_resource

  # add authentication for non devise controller
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_do_param, only: [:index, :new, :show, :edit], unless: :devise_controller?
  before_action :set_object_do_param, only: [:update, :create], unless: :devise_controller?
  before_action :set_commit_param, only: [:update, :create], unless: :devise_controller?
  before_action :set_form, only: [:edit, :new], unless: :devise_controller?

  def layout_by_resource
    if devise_controller?
      "single-column"
    else
      "application"
    end
  end


  def set_do_param
    _do = params[:_do]
    @do = _do.to_sym if _do && !_do.empty?
  end

  def set_object_do_param
    object = controller_name.singularize.to_sym
    _do = params[object][:_do]
    @do = _do.to_sym if _do && !_do.empty?
  end

  def set_form
    @form = @do.nil? ? "form" : "form_#{@do}"
  end

  def set_commit_param
    @commit = @@commit_map[params[:commit]]
  end

  def did
    @do
  end

  def update
    logger.debug "#{controller_name}#update, _do:#{@do}"
    update_proc = (@do.nil? ? "update_default" : "update_#{@do}").to_sym
    if self.respond_to?(update_proc)
      self.send(update_proc.to_sym)
    elsif self.respond_to?(:update_others)
      self.send(:update_others)
    else
      logger.warn "missing handler for route: #{controller_name}##{update_proc}"
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/404", :layout =>
          false, :status => :not_found }
      end
    end
  end

  @@commit_map = I18n.t("simple_form.commits").invert
end
