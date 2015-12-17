class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def page_not_found
    e = Error.new(:status => 404, :message => "Wrong URL or HTTP method")    
    render :json => e.to_json, :status => 404
  end

  # Helper function to check user authentication.
  # Params: user_id, token
  # Return: true/false
  def checkAuth(params)
		user = User.find_by(id: params[:uid])
		puts user
		if user && user.authtoken == params[:authtoken]
			return true
		else
			return false
		end
	end
end
