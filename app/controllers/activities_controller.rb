class ActivitiesController < ApplicationController
  def new
  end

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

  def getByUserID
    if checkAuth(params)
      user = User.find(params[:UserID])
      user = User.find(35)
      @user_id = user.id
      acts = ActiveRecord::Base.connection.exec_query(
        "SELECT * 
         FROM activities, memberactivities
         WHERE activities.id = memberactivities.activity_id AND 
               memberactivities.user_id = #{@user_id}
         ORDER BY start_time")
      act_arr = []
      acts.each do |a|
        act_arr << a
      end

  		# acts_id = Memberactivity.where(user_id: params[:UserID])
  		# acts = []
    #   acts_ids = []
    #   acts_id.each do |j| acts_ids << j.activity_id end 
    #   Activity.find(acts_ids, :order => "start_time")
  		# acts_id.each do |j| 
    #     acts << Activity.find_by(id: j.activity_id) 
    #   end	
    #   acts.sort_by! do |a| a[:start_time] end
    #   nacts = acts.sort_by do |a| a.start_time end

    #   nacts = acts.order("start_time")

      rtnacts = []
      act_arr.each do |a|
        if !a.nil?
          expired = false;
          if a["start_time"].to_time + a["duration"].to_i - Time.now < 0
            expired = true;
          end

          host = User.find(a["user_id"])

          rtnacts << {
            avatar:         host.avatar,
            actid:          a["id"].to_i,
            actType:        a["activity_type"],
            groupSize:      a["group_size"].to_i,
            location:       a["location"],
            startTime:      a["start_time"].to_time,
            duration:       a["duration"].to_i,
            comments:       a["comments"],
            # lat:            a["latitude"],
            # lng:            a["longitude"],
            currentNum:     a["member_number"].to_i,
            is_expired:     expired
          }
        end
      end
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

  def getByGeoInfo
  	if checkAuth(params)
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

  		#Activity.find_by_sql("SELECT activities.latitude, activities.longitude FROM activities WHERE longitude < 0 AND longitude > -10.176 AND latitude < 55 AND latitude > 50 ORDER BY start_time")

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
  	else
  		rtn = {
				errormsg: "Authentication Denied.",
        status:   "401"
      }
	    render :json => rtn
  	end
    
  end

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
