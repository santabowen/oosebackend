class ActivitiesController < ApplicationController
  def new
  end

  # Post a new activity
  # POST /activities/post
  # Params: user_id, token, activity_params: ActivityType, Location, GroupSize, 
  #         Comments, Duration, Lng, Lat, StartTime
  # Return: status: 201, 401, 404
  def post
  	if checkAuth(params)
  		@user = User.find_by(id: params[:HostID])
  		a = @user.activities.new(activity_params)
	    if @user and a.save
		    a.memberactivities.create(user_id: params[:HostID], activity_id: a.id)
	      print "Successfully create an activity."
	      rtn = {
	        status: "201"
	      }
				render :json => rtn
			else
				print "Fail to create an activity."
				rtn = {
					errormsg: "Fail to create an activity.",
	        status:   "404"
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

  # Get activities by user id.
  # POST /activities/getByUserID
  # Params: user_id, token
  # Return: status: 201, 401, 404
  #         acts: avatar, actid, actType, groupSize, location, 
  #         startTime, duration, comments, currentNum, is_expired
  def getByUserID
    if checkAuth(params)
      user = User.find(params[:UserID])
      @user_id = user.id
      acts = ActiveRecord::Base.connection.exec_query(
        "SELECT activities.*
         FROM activities, memberactivities
         WHERE activities.id = memberactivities.activity_id AND 
               memberactivities.user_id = #{@user_id}
         ORDER BY start_time")

      act_arr = []
      acts.each do |a|
        act_arr << a
      end

      rtnacts        = []
      acts_expired   = []
      acts_inexpired = []
      act_arr.each do |a|
        if !a.nil?
          host = User.find(a["user_id"])
          if a["start_time"].to_time + a["duration"].to_i - Time.now < 0
            acts_expired << {
              avatar:         host.avatar,
              actid:          a["id"].to_i,
              actType:        a["activity_type"],
              groupSize:      a["group_size"].to_i,
              location:       a["location"],
              startTime:      a["start_time"].to_time,
              duration:       a["duration"].to_i,
              comments:       a["comments"],
              currentNum:     a["member_number"].to_i,
              is_expired:     true
            }
          else
            acts_inexpired << {
              avatar:         host.avatar,
              actid:          a["id"].to_i,
              actType:        a["activity_type"],
              groupSize:      a["group_size"].to_i,
              location:       a["location"],
              startTime:      a["start_time"].to_time,
              duration:       a["duration"].to_i,
              comments:       a["comments"],
              currentNum:     a["member_number"].to_i,
              is_expired:     false
            }
          end
        end
      end
      rtnacts = acts_inexpired + acts_expired
      rtn = {
        acts:   rtnacts,
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

  # Get activities by current location.
  # POST /activities/getByGeoID
  # Params: user_id, token, Lng, Lat
  # Return: status: 201, 401, 404
  #         acts: avatar, actid, actType, groupSize, location, 
  #         startTime, duration, comments, currentNum, is_expired
  def getByGeoInfo
  	if !checkAuth(params)
      rtn = {
        errormsg: "Authentication Denied.",
        status:   "401"
      }
      render :json => rtn
    else
  		@min_lng = params[:Lng] - 0.045
  		@max_lng = params[:Lng] + 0.045
  		@min_lat = params[:Lat] - 0.045
  		@max_lat = params[:Lat] + 0.045

  		acts = Activity.find_by_sql(
        "SELECT * FROM activities 
         WHERE longitude < #{@max_lng} AND 
               longitude > #{@min_lng} AND 
               latitude < #{@max_lat} AND 
               latitude > #{@min_lat}
         ORDER BY start_time")

  		user = User.find_by(id: params[:uid])
  		filchecks = []
  		user.filters.each do |f|
  			filchecks << f.filtertype
  		end
	    rtnacts = []
	    acts.each do |a|

	      if a.start_time > Time.now and filchecks.include? a.activity_type
		      rtnacts << {
		      	avatar:         a.user.avatar,
		        actid:          a.id,
		        actType:        a.activity_type,
		        groupSize:      a.group_size,
		        location:       a.location,
		        startTime:      a.start_time,
		        duration:       a.duration,
		        comments:       a.comments,
		        lat:            a.latitude,
		        lng:            a.longitude,
		        currentNum:     a.member_number
		      }
		    end
	    end
	    rtn = {
	      acts:   rtnacts,
	      status: "201"
	    }
	    render :json => rtn
  	end
  end

  # Join an activity.
  # POST /activities/join
  # Params: user_id, token, ActID
  # Return: status: 201, 401
  def join
  	if checkAuth(params)
  		a = Activity.find_by(id: params[:ActID])
	    a.update(member_number: a.member_number + 1)
	    a.memberactivities.create(user_id: params[:UserID], activity_id: params[:ActID])
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

  # Drop an activity.
  # DELETE /activities/drop
  # Params: user_id, token, ActID
  # Return: status: 201, 401
	def drop
		if checkAuth(params)
  		a = Activity.find_by(id: params[:ActID])
			relation = a.memberactivities.find_by(user_id: params[:UserID])
			relation.delete
			a.update(member_number: a.member_number - 1)
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

  # Host drops an activity.
  # DELETE /activities/hostdrop
  # Params: user_id, token, ActID
  # Return: status: 201, 401
	def hostdrop
		if checkAuth(params)
  		a = Activity.find_by(id: params[:ActID])
  		if a.member_number == 1
  			a.delete
  		else
  			relation = a.memberactivities.find_by(user_id: params[:UserID])
				relation.delete

  			new_host_id = a.memberactivities.first.user_id
        a.hostid = new_host_id
        a.user_id = new_host_id

  			a.update(member_number: a.member_number - 1)
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
	
  # Get a single activity by activity id.
  # POST /activities/getsingle
  # Params: user_id, token, actID
  # Return: status: 201, 401
  #         acts: avatar, actid, actType, groupSize, location, 
  #         startTime, duration, comments, currentNum, is_expired
	def getsingle
		if checkAuth(params)
  		a = Activity.find_by(id: params[:actId])
			members = []
			
			a.memberactivities.each do |ma|
				user = User.find(ma.user_id)
				members << {
					uid:      ma.user_id,
					avatar:   user.avatar
				}
			end

			hostid = a.hostid
			host = User.find_by(id: hostid)

			rtnact = {
				actid:            a.id,
				hostid:           a.hostid,
				hostavatar:       host.avatar,
				actType:          a.activity_type,
				groupSize:        a.group_size,
				currentNum:       a.member_number,
				location:         a.location,
				startTime:        a.start_time,
				duration:         a.duration,
				comments:         a.comments,
				lng:              a.longitude,
				lat:              a.latitude,
				memberlist:       members
			}
			rtn = {
				act:    rtnact,
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

	private
		
    # Helper function to create a new activity.
    # Params: user_id, token, activity_params: ActivityType, Location, GroupSize, 
    #         Comments, Duration, Lng, Lat, StartTime
    # Return: activity
		def activity_params
			activity = Hash.new
			activity[:hostid]        = params[:HostID]
			activity[:activity_type] = params[:ActivityType]
			activity[:location]      = params[:Location]
			activity[:group_size]    = params[:GroupSize]
			activity[:comments]      = params[:Comments]
			activity[:duration]      = params[:Duration]
			activity[:longitude]     = params[:Lng]
			activity[:latitude]      = params[:Lat]
      activity[:start_time]    = params[:StartTime].to_time
			activity[:member_number] = 1
			return activity
		end
end
