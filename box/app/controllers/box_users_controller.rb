require 'securerandom'

      # puts @box_user.client_id
      # puts @box_user.client_index
      # puts @box_user.client_secret

class BoxUsersController < ApplicationController
  before_action :set_box_user, only: [:show, :edit, :update, :destroy]
  before_action :check_session, only: [:index]

  def index
    @box_user = BoxUser.new
  end

  def manage
    @box_user = BoxUser.where(:id => params[:key], :client_index => params[:value]).first
    if @box_user.nil?
      reset_session
      redirect_to action: "index"
    else
      @box_user
    end
  end

  def create
    @box_user = BoxUser.new(box_user_params)
    @box_user.client_index = SecureRandom.urlsafe_base64(n=64, padding=false) # should me moved to BoxUser model
    respond_to do |format|
      if @box_user.save
        set_session
        format.html { redirect_to action: "manage", key: @box_user.id, value: @box_user.client_index }
        format.json { render :manage, status: :created, location: @box_user }
      else
        format.html { render action: :index }
        format.json { render json: @box_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @box_user = BoxUser.where(:id => params[:key], :client_index => session[:client_index]).first # should be moved to BoxUserModel
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

    # Use callbacks to share common setup or constraints between actions.
    def check_session
      @box_user = BoxUser.where(:id => session[:box_id], :client_index => session[:client_index]).first # should be moved to BoxUserModel
      unless @box_user.nil? 
        redirect_to action: "manage", key: @box_user.id, value: @box_user.client_index
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
