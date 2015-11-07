class UsersController < ApplicationController
  def new
  end

  def create
		@user = User.new(user_params) 
		if @user.save
			print "Successfully creat a user."
			rtn = {
		  	status: "200"
		  }
			render :json => rtn
		else
			print "Fail to create a user."
			rtn = {
		  	status: "401"
		  }
			render :json => rtn
		end

	end


	private
		
		def user_params
			params[:password_confirmation] = params[:password]
			params.permit(:name, :email, :password, :password_confirmation)
		end
end
