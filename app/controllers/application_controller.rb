class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_do_param, only: [:index, :new, :show, :edit]
  before_action :set_object_do_param, only: [:update, :create]
  before_action :set_commit_param, only: [:update, :create]
  before_action :set_form, only: [:edit, :new]

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
    self.send("update_#{@do}".to_sym)
  end

  @@commit_map = I18n.t("simple_form.commits").invert
end
