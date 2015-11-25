class UsersController < ApplicationController
  def new
  end

  def create
    if params[:mode] == "fb"
      @graph = Koala::Facebook::API.new(params[:fbToken])
      profile = @graph.get_object("me")
		  @user = User.new(user_params_fb(profile)) 
    else
      @user = User.new(user_params)
    end
    
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

	def resetpw
		user = User.find_by(email: params[:email]) 
		if !user.nil?
			if Time.now - user.validation_time < 60*60
				validation_code = params[:validation_code]
		    	
		    	if validation_code == user.validation_code
			    	rtn = {
			  			status: "201"
			  		}
					render :json => rtn
					psw_token = BCrypt::Engine.hash_secret(params[:new_password], user.password_salt)
					user.update(password_digest: psw_token)
				else # validation code not correct
					rtn = {
	  				status: "401"
	  				}
					render :json => rtn
				end
			else # validation code expired
				rtn = {
	  				status: "402"
	  			}
				render :json => rtn
			end
		else # no such email found
			rtn = {
	  			status: "403"
	  		}
			render :json => rtn
		end
  	end

  	def changepw
  		user = User.find_by(email: params[:email]) 
		if !user.nil?
			if params[:old_password] == user.password_digest 
				validation_code = params[:validation_code]
		    
		    	rtn = {
		  			status: "201"
		  		}

				render :json => rtn
				psw_token = BCrypt::Engine.hash_secret(params[:new_password], @user.password_salt)
				user.update(password_digest: psw_token)
				
			else # validation code expired
				rtn = {
	  				status: "402"
	  			}
				render :json => rtn
			end
		else # no such email found
			rtn = {
	  			status: "403"
	  		}
			render :json => rtn
		end
  	end

	def signin
		rtn = {
	  	status: "401"
	  }
    if params && params[:email] && params[:password]        
      user = User.find_by(email: params[:email])
      
      if user 
        if User.authenticate(user, params[:password])
          rtn = returnparams(user)
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

  def forgetpw
	user = User.find_by(email: params[:email])
	# print params[:email]
	# UserMailer.forget_password_confirmation(@user).deliver
	if !user.nil?

   	 	validation_code = rand_string(6)
    	validation_time = Time.now

    	user.update(validation_code: validation_code)
    	# print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
    	# print user.errors.messages
    	# print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
    	user.update(validation_time: validation_time)
    	# print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
    	# print user.errors.messages
    	# print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

		rtn = {
  			status: "201"
  		}
		render :json => rtn

		# UserMailer.forget_password_confirmation(@user).deliver_now

	    validation_code = rand_string(6)
	    validation_time = Time.now
	    user.update(validation_time: validation_time, validation_time: validation_time)
	else
		rtn = {
  		status: "404"
  		}
		render :json => rtn
	end
  end

  def fblogin
    @graph = Koala::Facebook::API.new(params[:fbToken])
    profile = @graph.get_object("me")
    print "~~~~~~~~~~~~~~~~~~~~~~"
    print profile
    print "~~~~~~~~~~~~~~~~~~~~~~"
    user = User.find_by(email: params[:email])
    if user.nil?
      @user = User.new(user_params_fb(profile))
      if @user.save
        user = User.find_by(email: params[:email])
        print "Successfully creat a user."
        rtn = returnparams(user)
        render :json => rtn
      else
        print "Fail to create a user."
        rtn = {
          status: "401"
        }
        render :json => rtn
      end
    else
      rtn = returnparams(user)
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

    def user_params_fb(profile)
      user = Hash.new
      user[:name]      = profile["name"]
      user[:email]     = params["email"]
      user[:password]  = rand_string(15)
      user[:gender]    = params["gender"]
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

    def returnparams(user)
      rtn = {
        name:       user.name,
        uid:        user.id,
        authtoken:  user.authtoken,
        status:     "200",
        avatarUrl:  "https://graph.facebook.com/127235060968514/picture?type=large"
      }
    end
end
