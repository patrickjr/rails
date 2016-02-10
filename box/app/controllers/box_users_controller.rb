require 'securerandom'

class BoxUsersController < ApplicationController
  before_action :set_box_user, only: [:show, :edit, :update, :destroy]
  before_action :check_session, only: [:index]

  def index
    @box_user = BoxUser.new
  end

  def attributes
    validate_session
    unless @box_user.nil?
      @box_user.request_file_info params[:folder_id]
      @box_user
    end
  end

  def folder
    validate_session
    unless @box_user.nil?
      @box_user.request_folder_recursively params[:folder_id]
      @box_user
    end
  end

  def manage
    @box_user = BoxUser.where(:id => params[:id], :client_index => session[:client_index]).first # should be moved
    if @box_user.nil?
      reset_session
      redirect_to action: "index"
    else
      @box_user
    end
  end

  def oauth_validate
    if validate_security_token
      @box_user = BoxUser.where(:id => params[:id], :client_index => params[:state]).first # should be moved
      @box_user.request_access_token params[:code]
      @box_user.save
    else
      reset_session
    end
      redirect_to action: "index"
  end

  def create
    @box_user = BoxUser.new(box_user_params)
    @box_user.client_index = SecureRandom.urlsafe_base64(n=64, padding=false) # should me moved to BoxUser model
    respond_to do |format|
      if @box_user.save
        set_session
        format.html { redirect_to @box_user.oauth_url }
        format.json { render :manage, status: :created, location: @box_user }
      else
        format.html { render action: :index }
        format.json { render json: @box_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @box_user = BoxUser.where(:id => params[:id], :client_index => session[:client_index]).first # should be moved to BoxUserModel
    if @box_user.nil?
      reset_session
      redirect_to action: "index"
    else
      @box_user.destroy
      respond_to do |format|
        format.html { redirect_to action: "index" }
        format.json { head :no_content }
      end
    end
  end

  private

    def validate_security_token
      !BoxUser.where(:id => params[:id], :client_index => params[:state]).first.nil? # should be moved
    end

    # Use callbacks to share common setup or constraints between actions.
    def check_session
      @box_user = BoxUser.get_from(session)
      unless @box_user.nil? 
        redirect_to action: "manage", id: @box_user.id
      end
    end

    def validate_session
      @box_user = BoxUser.get_from(session)
      if @box_user.nil?
        reset_session
        redirect_to action: "index"
      end
    end

    def set_session
      session[:client_index] = @box_user.client_index
      session[:box_id] = @box_user.id
    end

    def set_box_user
      @box_user = BoxUser.find(params[:id])
    end

    def box_user_params
      params.require(:box_user).permit(:client_id, :client_secret, :client_index)
    end
end
