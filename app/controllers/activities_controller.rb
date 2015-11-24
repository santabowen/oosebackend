class ActivitiesController < ApplicationController
  def new
  end

  def post
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
		  	status: "404"
		  }
			render :json => rtn
		end
	end

	def get
		rtnacts = []
		acts = Activity.all
		acts.each do |a|
			rtnacts << {
				actid:          a.id,
				actType:        a.activityType,
				groupSize:      a.groupSize,
				location:       a.location,
				startTime:      a.startTime,
				duration:       a.duration,
				comments:       a.comments
			}
		end
		rtn = {
			acts:   rtnacts,
	  	status: "201"
	  }
		render :json => rtn
	end

	def join
		a = Activity.find_by(id: params[:ActID])
		a.update(memberNum: a.memberNum + 1)
		a.memberactivities.create(user_id: params[:UserID], activity_id: params[:ActID])
		rtn = {
	  	status: "201"
	  }
		render :json => rtn
	end

	def drop
		a = Activity.find_by(id: params[:ActID])
		relation = a.memberactivities.find_by(user_id: params[:UserID])
		relation.delete
		rtn = {
	  	status: "201"
	  }
		render :json => rtn
	end
	
	def getsingle
		a = Activity.find_by(id: params[:actId])
		members = []
		
		a.memberactivities.each do |ma|
			members << {
				uid:      ma.user_id
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
			activity[:memberNum]     = 1
			return activity
		end
end
