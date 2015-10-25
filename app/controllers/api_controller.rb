class ApiController < ApplicationController

	def changeLogo
		print "~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		user = []
		user << {
	    name: "Xiang Chen"
	  }
	  user << {
	    name: "Hui Lin"
	  }
	  rtn = {
	  	user: user
	  }
	  print rtn
		render :json => rtn
	end

	def postRequest
		print "This is my new post request."
		print params
	  rtn = {
	  	status: "422"
	  }
		render :json => rtn
	end

	# def getActivities
	# 	print "~~~~~~~~~~~~~~~~~~~~"
	# 	activities = []
	# 	activities << {
	# 		activityType:    "badminton",
	# 		location:        "Broadview",
	# 		time:            "20151212",
	# 		groupSize:       "5",
	# 		memberNum:       "3"
	# 	}
	# 	activities << {
	# 		activityType:    "basketball",
	# 		location:        "University",
	# 		time:            "20151010",
	# 		groupSize:       "12",
	# 		memberNum:       "8"
	# 	}
	# 	rtn = {
	# 		activities
	# 	}
	# 	render :json => rtn
	end


end