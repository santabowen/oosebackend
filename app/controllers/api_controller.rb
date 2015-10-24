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

end