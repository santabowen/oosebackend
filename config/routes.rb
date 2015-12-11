Rails.application.routes.draw do

  root     'home#index'
  post     'users/signin'
  post     'users/forgetpw'
  post     'users/resetpw'
  post     'users/fblogin'
  post     'users/changepw'
  post     'users/rating'
  post     'users/ratemember'
  post     'users/updateprofile'
  get      'users/getprofile'
  post     'users/setFilter'

  post     'activities/post'
  post     'activities/getsingle'
  post     'activities/getByGeoInfo'
  post     'activities/getByUserID'
  post     'activities/join'
  delete   'activities/drop'
  delete   'activities/hostdrop'

  resources    :ratings
  resources    :users
  resources    :activities
  resources    :microposts,   only: [:create, :destroy]
  
end
