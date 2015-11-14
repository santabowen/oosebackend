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

	def signin
		rtn = {
	  	status: "401"
	  }
    if params && params[:email] && params[:password]        
      @user = User.find_by(email: params[:email])
      
      if @user 
        if User.authenticate(@user, params[:password])
          rtn = {
          	name:       @user.name,
          	uid:        @user.id,
          	authtoken:  @user.authtoken,
          	status: 		"200",
          	avatarUrl:  "https://graph.facebook.com/127235060968514/picture?type=large"
          }
          render :json => rtn
        else
          # e = Error.new(status: 401, message: "Wrong Password")
          render :json => rtn
        end      
      else
        # e = Error.new(status: 400, message: "No USER found by this email ID")
        render :json => rtn
      end
    else
      # e = Error.new(status: 400, message: "required parameters are missing")
      render :json => rtn
    end
  end


	private
		
		def user_params
			user = Hash.new
			user[:name]      = params[:name]
			user[:email]     = params[:email]
			user[:password]  = params[:password]
			user[:gender]    = params[:gender]
			user[:authtoken] = rand_string(20)
			return user
		end

		def check_for_valid_authtoken
	    authenticate_or_request_with_http_token do |token, options|     
	      @user = User.where(:api_authtoken => token).first      
	    end
	  end
	  
	  def rand_string(len)
	    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
	    string  =  (0..len).map{ o[rand(o.length)]  }.join

	    return string
	  end
end
