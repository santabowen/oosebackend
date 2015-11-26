Rails.application.routes.draw do

  resources :ratings
  root     'home#index'
  post     'users/signin'
  post     'users/forgetpw'
  post     'users/resetpw'
  post     'users/fblogin'
  post     'users/changepw'
  post     'users/rating'
  post     'users/ratemember'
  post     'users/updateprofile'
  post     'users/getprofile'

  post     'activities/post'
  get      'activities/getsingle'
  post     'activities/getByGeoInfo'
  post     'activities/getByUserID'
  post     'activities/join'
  delete   'activities/drop'


  resources    :users
  resources    :activities
  
end
