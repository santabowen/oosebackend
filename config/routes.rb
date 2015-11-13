Rails.application.routes.draw do

  root         'home#index'
  get          'users/signin'
  get          'users/fbsignin'
  post         'activities/post'
  get          'activities/getsingle'
  get          'activities/get'
  post				 'activities/join'

  resources    :users
  resources    :activities
  
end
