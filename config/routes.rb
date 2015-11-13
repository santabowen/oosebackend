Rails.application.routes.draw do

  root                  'home#index'
  get  'signin'     =>  'users/signin'
  get  'fbsignin'   =>  'users/fbsignin'
  post 'postact'    =>  'activities/post'
  get  'getacts'    =>  'activities/getsingle'
  get  'getact'     =>  'activities/get'
  post 'join'    	  =>  'activities/join'

  resources    :users
  resources    :activities
  
end
