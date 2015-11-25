Rails.application.routes.draw do

  root     'home#index'
  post     'users/signin'
  post     'users/forgetpw'
  post     'users/resetpw'
  post     'users/fblogin'

  post     'activities/post'
  get      'activities/getsingle'
  get      'activities/get'
  post     'activities/join'
  delete   'activities/drop'


  resources    :users
  resources    :activities
  
end
