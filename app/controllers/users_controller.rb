class UsersController < ApplicationController
  def new
  end

  # Create a new user.
  # POST /users
  # Params: mode, email, name, password, gender
  # Return: status: 200, 401
  def create
    if params[:mode] == "fb"
      @graph = Koala::Facebook::API.new(params[:fbToken])
      profile = @graph.get_object("me")
		  @user = User.new(user_params_fb(profile)) 
    else
      emailcheck = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i =~ params[:email]
      if emailcheck.nil?
        print "Email Wrong Format."
        rtn = {
          errormsg: "Email Wrong Format.",
          status:   "401"
        }
      end
      @user = User.new(user_params)
    end
		if @user.save
			@user = createFilters(@user)
			print "Successfully creat a user."
			rtn = {
        errormsg: "You succeed!",
		  	status:   "200"
		  }
			render :json => rtn
		else
			if !User.find_by(email: params[:email]).nil?
  			rtn = {
          errormsg: "Existing email!",
  		  	status:   "401"
  		  }
      end
      rtn = {
        errormsg: "Other Faults.",
        status:   "401"
      }
			render :json => rtn
		end
	end

  # Reset a user's password.
  # POST /users/resetpw
  # Params: mode, email, validation_code, new_password
  # Return: status: 201, 401, 402, 403
	def resetpw
		user = User.find_by(email: params[:email]) 
		if !user.nil?
			if Time.now - user.validation_time < 60 * 60
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

  # Change a new's password.
  # POST /users/changepw
  # Params: mode, email, old_password, new_password
  # Return: status: 201, 401, 402, 403
	def changepw
    if checkAuth(params)
      user = User.find(params[:uid]) 
      if !user.nil?
        old_psw_token = BCrypt::Engine.hash_secret(params[:old_password], user.password_salt)
        if old_psw_token == user.password_digest
          user.update(password: params[:new_password])
          rtn = {
            status: "201"
          }
          render :json => rtn
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
    else
      rtn = {
        errormsg: "Authentication Denied.",
        status:   "401"
      }
      render :json => rtn
    end
	end

  # User log in.
  # POST /users/signin
  # Params: email, password
  # Return: status: 201, 401, 402, 403
  #         parameters: user.name, user.id, user.authtoken, user.avatar
	def signin
    if params && params[:email] && params[:password]        
      user = User.find_by(email: params[:email])
      
      if !user.nil?
        if User.authenticate(user, params[:password])
          rtn = returnparams(user)
          rtn = {
            status: "201"
          }
          render :json => rtn
        else
          rtn = {
            status: "401"
          }
          # e = Error.new(status: 401, message: "Wrong Password")
          render :json => rtn
        end      
      else
        rtn = {
          status: "402"
        }
        # e = Error.new(status: 400, message: "No USER found by this email ID")
        render :json => rtn
      end
    else
      rtn = {
        status: "403"
      }
      # e = Error.new(status: 400, message: "required parameters are missing")
      render :json => rtn
    end
  end

  # User forget password, and backend sends email.
  # POST /users/forgetpw
  # Params: email
  # Return: status: 201, 404
  def forgetpw
		user = User.find_by(email: params[:email])
		if !user.nil?

	 	 	validation_code = rand_string(6)
	  	validation_time = Time.now
	  	user.update(validation_code: validation_code)
	  	user.update(validation_time: validation_time)

			rtn = {
  			status: "201"
  		}
			render :json => rtn

			UserMailer.forget_password_confirmation(user).deliver_now
		else
			rtn = {
	  		status: "404"
	  	}
			render :json => rtn
		end
  end

  # User facebook login
  # POST /users/fblogin
  # Params: email, fbToken
  # Return: status: 200, 401
  #         parameters: user.name, user.id, user.authtoken, user.avatar
  def fblogin
    @graph = Koala::Facebook::API.new(params[:fbToken])
    profile = @graph.get_object("me")
    user = User.find_by(email: params[:email])
    if user.nil?
      @user = User.new(user_params_fb(profile))
      if @user.save
        @user = createFilters(@user)
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

  # User rates others.
  # POST /users/ratemember
  # Params: user_id, user_token, act_id, uid, members
  # Return: status: 200, 401
  #         parameters: user.name, user.id, user.authtoken, user.avatar
  def ratemember
    if checkAuth(params)
      act_id = params[:act_id]
      user_id = params[:uid]
      members = params[:members]

      members.each do |ma|
        member_id = ma[:member_id]
        rating = ma[:rating]
        rate = Rating.find_by(activity_id: act_id, user_id: user_id, member_id: member_id)
        user = User.find(member_id)
        if !rate.nil?
          new_rating = (user.total_rating - rate.rating + rating) / user.num_rating
          rate.update(rating: rating)
          user.update(total_rating: user.total_rating - rate.rating + rating, rating: new_rating)
        else
          Rating.create(activity_id: act_id, user_id: user_id,
                member_id: member_id, rating: rating)
          new_rating = (user.total_rating + rating) / (user.num_rating + 1)
          user.update(num_rating: user.num_rating + 1, 
            total_rating: user.total_rating + rating, rating: new_rating)
        end
      end
      rtn = {
        status: "201"
      }
      render :json => rtn
      
    else
      rtn = {
        errormsg: "Authentication Denied.",
        status:   "401"
      }
      render :json => rtn
    end
  end

  # User rates others.
  # POST /users/ratemember
  # Params: user_id, user_token, act_id, uid, members
  # Return: status: 200, 404
  #         parameters: user.name, user.id, user.authtoken, user.avatar
  def rating

    if checkAuth(params)
      
      act_id = params[:act_id]
      user_id = params[:uid]
      authtoken = params[:authtoken]
      act = Activity.find_by(id: act_id)
      ratings = []
      # print user_id
      
      if act.nil?
        rtn = {
          status:    "404"
        }
        render :json => rtn
      else
        inThegroup = 0
        act.memberactivities.each do |ma|
          if ma.user_id == Integer(user_id)
            inThegroup = 1
          end
        end

        if inThegroup == 0
          rtn = {
            status:    "404"
          }
          render :json => rtn
        else
          act.memberactivities.each do |ma|
            member_id = ma.user_id
            member = User.find_by(id: member_id)
            member_name = member.name
            member_avatar = member.avatar
            member_gender = member.gender

            # if member_id != Integer(user_id)
              
            rate = Rating.find_by(activity_id: act_id, user_id: user_id, member_id: member_id)

            if !rate.nil?
              ratings << {
                member_id:          member_id,
                member_name:        member_name,
                member_avatar:      member_avatar,
                member_gender:      member_gender,
                rating:             rate.rating
              }
            else
              ratings << {
                member_id:          member_id,
                member_name:        member_name,
                member_avatar:      member_avatar,
                member_gender:      member_gender,
                rating:             -1
              }
            end
          end
          rtn = {
            members:   ratings,
            status:    "201"
          }
          render :json => rtn
        end
      end
      
    else
      rtn = {
        errormsg: "Authentication Denied.",
        status:   "401"
      }
      render :json => rtn
    end
  end

  # User updates profile.
  # POST /users/updateprofile
  # Params: user_id, user_token, type(update), value
  # Return: status: 201, 401
  def updateprofile
  	if checkAuth(params)
  		user = User.find_by(id: params[:uid])
  		case params[:type]
  		when "avatar"
  			user.update(avatar: params[:avatar])
  		when "name"
  			user.update(name: params[:name])
  		when "address"
  			user.update(address: params[:address])
  		when "self_description"
  			user.update(self_description: params[:self_description])
  		else
  			puts "No such attributes"
  		end

			rtn = {
		  		status:  "201"
		  	}
			render :json => rtn
  	else
  		rtn = {
				errormsg: "Authentication Denied.",
        status:   "401"
      }
	    render :json => rtn
  	end
  end

  # User gets profile.
  # GET /users/updateprofile
  # Params: user_id, user_token, type(update), value
  # Return: status: 201, 401
  #         profile: avatar, name, address, email, rating, self_description
  def getprofile
  	if checkAuth(params)
  		
  		user = User.find_by(id: params[:viewUid])
			profile = {
				avatar:           user.avatar,
				name:             user.name,
				address:          user.address,
				email:            user.email,
        rating:           user.rating,
				self_description: user.self_description
			}
			rtn = {
				profile: profile,
		  	status:  "201"
		  }
			render :json => rtn
  	else
  		rtn = {
				errormsg: "Authentication Denied.",
        status:   "401"
      }
	    render :json => rtn
  	end
  end

  # User updates filters.
  # POST /users/updateFilter
  # Params: user_id, user_token, filterDict
  # Return: status: 201, 401
  def updateFilter
    if checkAuth(params)
      updateFilters(@user, params[:filterDict])
      rtn = {
        status:   "201"
      }
      render :json => rtn
    else
      rtn = {
        errormsg: "Authentication Denied.",
        status:   "401"
      }
      render :json => rtn
    end
  end

  # User sets filters.
  # POST /users/updateFilter
  # Params: user_id, user_token, filterDict
  # Return: status: 201, 401
  def setFilter
    if checkAuth(params)
      user = User.find(params[:uid])
      user = updateFilters(user, params[:filter])
      rtn = {
        status:   "201"
      }
      render :json => rtn
    else
      rtn = {
        errormsg: "Authentication Denied.",
        status:   "401"
      }
      render :json => rtn
    end
  end

	private
		# Helper method for user's parameters when create users.
    # Params: name, email, password, gender, avatarUrl
    # Return: new User
		def user_params
			user = Hash.new
			user[:name]         = params[:name]
			user[:email]        = params[:email]
			user[:password]     = params[:password]
			user[:gender]       = params[:gender]
			user[:authtoken]    = rand_string(20)
      user[:avatar]       = params["avatarUrl"]
      user[:num_rating]   = 0
      user[:total_rating] = 0
      user[:rating]       = 0
			return user
		end

    # Helper method for user's parameters when fb login.
    # Params: name, email, gender
    # Return: new User
    def user_params_fb(profile)
      user = Hash.new
      user[:name]         = profile["name"]
      user[:email]        = params["email"]
      user[:password]     = rand_string(15)
      user[:gender]       = params["gender"]
      user[:authtoken]    = rand_string(20)
      user[:num_rating]   = 0
      user[:total_rating] = 0
      user[:rating]       = 0
      return user
    end

    # Helper function to generate certain sized random number.
    # Params: length
    # Return: random number
	  def rand_string(len)
	    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
	    string  =  (0..len).map{ o[rand(o.length)] }.join
	    return string
	  end

    # Helper function to return rtn object.
    # Params: user
    # Return: rtn
    def returnparams(user)
      rtn = {
        name:       user.name,
        uid:        user.id,
        authtoken:  user.authtoken,
        status:     "200",
        avatarUrl:  user.avatar
      }
    end

    # Helper function to return rtn object.
    # Params: user
    # Return: user
    def createFilters(user)
			user.filters.create(filtertype: "Basketball")
			user.filters.create(filtertype: "Tennis")
			user.filters.create(filtertype: "Gym")
			user.filters.create(filtertype: "Badminton")
			user.filters.create(filtertype: "Jogging")
			user.filters.create(filtertype: "Others")
			return user
		end

    # Helper function to update user's filter.
    # Params: user, filterlist
    # Return: user
	  def updateFilters(user, filterlist)
			filts = user.filters
      filts.each do |a|
        a.delete
      end
      filterlist.each do |fl|
        user.filters.create(filtertype: fl)
      end
      return user
		end
end



