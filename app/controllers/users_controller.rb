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
			@user = createFilters(@user)
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

	def signin
		rtn = {
	  	status: "401"
	  }
    if params && params[:email] && params[:password]        
      user = User.find_by(email: params[:email])
      
      if !user.nil?
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

  def ratemember

    if checkAuth(params)
      
      act_id = params[:act_id]
      user_id = params[:uid]
      authtoken = params[:authtoken]
      members = params[:members]

      members.each do |ma|
        member_id = ma[:member_id]
        rating = ma[:rating]
        rate = Rating.find_by(activity_id: act_id, user_id: user_id, member_id: member_id)
        if !rate.nil?
          Rating.update(activity_id: act_id, user_id: user_id,
                member_id: member_id, rating:rating)
          user = User.find(member_id)
          new_rating = (user.rating + rating) / (user.num_rating + 1)
          user.update(num_rating: user.num_rating + 1, 
            total_rating: user.total_rating + rating, rating: new_rating)
        else
          Rating.create(activity_id: act_id, user_id: user_id,
                member_id: member_id, rating:rating)
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

  def getprofile
  	if checkAuth(params)
  		
  		user = User.find_by(id: params[:uid])
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
		  puts "~~~~~~~~~~~~~"
		  puts profile
			render :json => rtn
  	else
  		rtn = {
				errormsg: "Authentication Denied.",
        status:   "401"
      }
	    render :json => rtn
  	end
  end

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
		
		def user_params
			user = Hash.new
			user[:name]         = params[:name]
			user[:email]        = params[:email]
			user[:password]     = params[:password]
			user[:gender]       = params[:gender]
			user[:authtoken]    = rand_string(20)
      user[:num_rating]   = 0
      user[:total_rating] = 0
      user[:rating]       = 0
			return user
		end

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

	  # def check_for_valid_authtoken
	  #   authenticate_or_request_with_http_token do |token, options|     
	  #     @user = User.where(:api_authtoken => token).first      
	  #   end
	  # end
	  
	  def rand_string(len)
	    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
	    string  =  (0..len).map{ o[rand(o.length)] }.join
	    return string
	  end

    def returnparams(user)
      rtn = {
        name:       user.name,
        uid:        user.id,
        authtoken:  user.authtoken,
        status:     "200",
        avatarUrl:  user.avatar
      }
    end

    def createFilters(user)
			user.filters.create(filtertype: "Basketball")
			user.filters.create(filtertype: "Tennis")
			user.filters.create(filtertype: "Gym")
			user.filters.create(filtertype: "Badminton")
			user.filters.create(filtertype: "Jogging")
			user.filters.create(filtertype: "Others")
			return user
		end

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



