class AdminsController < ApplicationController
  http_basic_authenticate_with name: "admin", password: "Ar1m4!@#"

  before_filter :simple_admin
  before_filter :setup
  before_filter :restrict

  layout "admin"

  def index
  end

  def model_index
    @resources = @model_name.constantize.page(params[:page]).order('updated_at DESC') || []
    render :index
  end

  def model_edit
    @resource = @sa.get_resource(params[:model_name], params[:id])
  end

  def model_new
    @resource = @sa.new_resource(params[:model_name])
  end

  def update
    form_params = params[@model_name.underscore]
    @resource = @sa.get_resource(@model_name, params[:id])
    @resource.assign_attributes form_params.to_h.symbolize_keys!

    if @resource.save
      redirect_to admin_model_index_path @model_name
    else
      flash[:error] = "Could not update #{@model_name}! – #{@resource.errors.messages.to_a.join(", ")}"
      redirect_to admin_model_edit_path(@model_name, params[:id])
    end
  end

  def create
    form_params = params[@model_name.underscore]
    @resource = @sa.new_resource(@model_name)
    @resource.assign_attributes form_params.to_h.symbolize_keys!

    if @resource.save
      redirect_to admin_model_index_path @model_name
    else
      flash[:error] = "Could not create #{@model_name}! – #{@resource.errors.messages.to_a.join(", ")}"
      redirect_to admin_model_new_path @model_name
    end
  end

  def destroy
    @resource = @sa.get_resource(@model_name, params[:id])
    @resource.destroy!
    redirect_to admin_model_index_path @model_name
  end

  def extension
    @extension = @sa.extensions.find{ |ext| ext.class_name == params[:name].camelize }
    @extension_instance = @extension.instantiate

    render "admins/extensions/#{params[:name]}"
  end

  def extension_post
    @extension = @sa.extensions.find{ |ext| ext.class_name == params[:name].camelize }
    @extension_instance = @extension.instantiate

    if params[:data].present?
      @extension_instance.data = params[:data].tempfile

      if @extension_instance.process!
        flash[:notice] = @extension_instance.flash_notice
      else
        flash[:alert] = @extension_instance.flash_alert
      end
    else
      flash[:alert] = "No data value present!"
    end

    redirect_to admin_extension_path(params[:name])
  end

  private

  def simple_admin
    @sa = SimpleAdmin.new

    @sa.model_blacklist =["GroupsQuestion"]

    @sa.visible_columns_blacklist = [
      "encrypted_password",
      "reset_password_token",
      "reset_password_sent_at",
      "remember_created_at",
      "current_sign_in_ip",
      "last_sign_in_ip",
      "current_sign_in_at",
      "last_sign_in_at",
      "created_at",
      "updated_at",
      "avatar_file_name",
      "avatar_content_type",
      "avatar_file_size",
      "avatar_updated_at",
      "measurement_unit",
      "currency_unit",
      "options_for_collection",
      "daily_score_award_date"
    ]

    @sa.editable_columns_blacklist = [
      "id",
      "user_id",
      "encrypted_password",
      "reset_password_token",
      "reset_password_sent_at",
      "remember_created_at",
      "current_sign_in_ip",
      "last_sign_in_ip",
      "current_sign_in_at",
      "last_sign_in_at",
      "created_at",
      "updated_at",
      "sign_in_count",
      "country",
      "continent",
      "avatar_file_name",
      "avatar_content_type",
      "avatar_file_size",
      "avatar_updated_at",
      "measurement_unit",
      "currency_unit",
      "question_id",
      "daily_score_award_date"
    ]

    @sa.creatable_models_whitelist = ["Question", "Group"]

    @sa.editable_associations_whitelist = {
      "Question" => [:groups]
    }

    @sa.extensions = {
      lib_class_name: 'UploadDummyData'
    }
  end

  def setup
    @table_models = @sa.table_models
    @creatable_resources = @sa.creatable_models_whitelist
  end

  def restrict
    # make sure we only try to access what we can
    return unless params[:model_name]
    @model_name = params[:model_name]
    render(text: "Could not access that Model", status: 401) unless @table_models.map(&:name).include?(@model_name)
  end
end
