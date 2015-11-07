class ActivitiesController < ApplicationController
  def new
  end

  def post
		@act = Activity.new(activity_params) 
		if @act.save
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


	private
		
		def activity_params
			activity = Hash.new
			activity[:activityType]  = params[:ActivityType]
			activity[:location]      = params[:Location]
			activity[:groupSize]     = params[:GroupSize]
			activity[:comments]      = params[:Comments]
			activity[:startTime]     = params[:StartTime]
			activity[:hostid]        = params[:HostID]
			activity[:duration]      = params[:Duration]
			return activity
		end
end
