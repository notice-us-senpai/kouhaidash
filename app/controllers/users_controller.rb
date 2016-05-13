class UsersController < ApplicationController
  before_action :get_user, only: [:show, :edit]

  def show
  end

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(user_params)
    if @user.save
      log_in @user
      remember @user
    	flash[:success] = "Welcome to KouhaiDash!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

 	private
  
   	def user_params
   		params.require(:user).permit(
   			:username, :email, 
   			:password, :password_confirmation, 
   			:name, :birthday, :description, 
   			:picture, 
   			:organisation, :position
  		)
  	end

    def get_user
      @user = User.find(params[:id])
    end
end
