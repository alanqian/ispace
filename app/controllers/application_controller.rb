class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :layout_by_resource

  # add authentication for non devise controller
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_do_param, only: [:index, :new, :show, :edit], unless: :devise_controller?
  before_action :set_object_do_param, only: [:update, :create], unless: :devise_controller?
  before_action :set_commit_param, only: [:update, :create], unless: :devise_controller?
  before_action :set_form, only: [:edit, :new, :update, :create], unless: :devise_controller?
  before_action :set_show, only: [:show], unless: :devise_controller?
  before_action :set_full_action
  before_action :set_user_info

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def layout_by_resource
    if devise_controller? and !current_user
      "single-column"
    else
      "application"
    end
  end

  def set_user_info
    user = self.current_user
    if user != nil
      role = user.role if user.respond_to?(:role)
      @current_user_role = role.to_sym if role.is_a?(String)
      @current_user_id = user.id if user.respond_to?(:id)
      @current_user_store_id = user.store_id if user.respond_to?(:store_id)
    end
  end

  def edit_update_do(_do)
    @do = _do
    @form = "form_#{@do}"
    params[:_do] = @do.to_s
    set_full_action
  end

  def set_do_param
    _do = params[:_do]
    @do = _do.to_sym if _do && !_do.empty?
  end

  def set_object_do_param
    object = controller_name.singularize.to_sym
    if params[object]
      _do = params[object][:_do]
      @do = _do.to_sym if _do && !_do.empty?
    end
  end

  def set_form
    @form = @do.nil? ? "form" : "form_#{@do}"
  end

  def set_show
    @show = @do.nil? ? "show" : "show_#{@do}"
  end

  def set_commit_param
    @commit = @@commit_map[params[:commit]]
  end

  def did
    @do
  end

  def set_full_action
    @full_action = @do.nil? ? "#{action_name}" : "#{action_name}_#{@do}"
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

  # = f.label :name, Product.human_attribute_name("labels.name").html_safe
  # I18n.t("foo", link: "abc")
  def simple_notice(options={})
    message = options[:message] || @full_action
    object = controller_name.singularize
    notice_text = I18n.t("simple_form.notices.#{object}.#{message}", options)
  end

  @@commit_map = I18n.t("simple_form.commits").invert
  @@object_label_methods = [:to_label, :name, :title]
end
