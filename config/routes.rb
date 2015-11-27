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
<<<<<<< HEAD
  post     'activities/getsingle'
=======
  post      'activities/getsingle'
>>>>>>> 15674079b25a330bdf96288c8188996b2ee37e9d
  post     'activities/getByGeoInfo'
  post     'activities/getByUserID'
  post     'activities/join'
  delete   'activities/drop'


  resources    :users
  resources    :activities
  
end
