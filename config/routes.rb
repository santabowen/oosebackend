Rails.application.routes.draw do

  root     'home#index'
  post     'users/signin'
  get      'users/fbsignin'
  post     'activities/post'
  get      'activities/getsingle'
  get      'activities/get'
  post     'activities/join'
  delete   'activities/drop'

  resources    :users
  resources    :activities
  
end
