class ActivitiesController < ApplicationController
  def new
  end

  def post
  	if checkAuth(params)
  		@user = User.find_by(id: params[:HostID])
	    if @user and @user.activities.create(activity_params) 
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
  		acts_id = Memberactivity.where(user_id: params[:UserID])
  		acts = []
  		acts_id.each do |j|
  			acts << Activity.find_by(id: j.activity_id)
  		end	

	    rtnacts = []
	    acts.each do |a|
	      expired = 0;
	      if a.startTime + a.duration - Time.now <= 0
	      	expired = 1;
	      end


	      rtnacts << {
	      	avatar:         a.user.avatar,
	        actid:          a.id,
	        actType:        a.activityType,
	        groupSize:      a.groupSize,
	        location:       a.location,
	        startTime:      a.startTime,
	        duration:       a.duration,
	        comments:       a.comments,
	        lat:            a.latitude,
	        lng:            a.longitude,
	        currentNum:     a.memberNum

	      }
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
  			"SELECT * 
  			 FROM activities
  			 WHERE longitude < #{@max_lng} AND 
  			 			 longitude > #{@min_lng} AND 
  			 			 latitude < #{@max_lat} AND 
  			 			 latitude > #{@min_lat}
  			 ORDER BY id DESC
  			")
  		
	    rtnacts = []
	    acts.each do |a|
	      rtnacts << {
	      	avatar:         a.user.avatar,
	        actid:          a.id,
	        actType:        a.activityType,
	        groupSize:      a.groupSize,
	        location:       a.location,
	        startTime:      a.startTime,
	        duration:       a.duration,
	        comments:       a.comments,
	        lat:            a.latitude,
	        lng:            a.longitude,
	        currentNum:     a.memberNum
	      }
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
	    a.update(memberNum: a.memberNum + 1)
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
			a.update(memberNum: a.memberNum - 1)
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
			rtnact = {
				actid:            a.id,
				actType:          a.activityType,
				groupSize:        a.groupSize,
				currentGroupSize: a.memberNum,
				location:         a.location,
				startTime:        a.startTime,
				duration:         a.duration,
				comments:         a.comments,
				longitude:        a.longitude,
				latitude:         a.latitude,
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
			activity[:activityType]  = params[:ActivityType]
			activity[:location]      = params[:Location]
			activity[:groupSize]     = params[:GroupSize]
			activity[:comments]      = params[:Comments]
			activity[:duration]      = params[:Duration]
			activity[:longitude]     = params[:Lng]
			activity[:latitude]      = params[:Lat]
      activity[:startTime]     = params[:StartTime].to_time
			activity[:memberNum]     = 1
			return activity
		end
end
