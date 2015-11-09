Rails.application.routes.draw do

  get 'sessions/new'

  root         'home#index'
  get          'api/changeLogo'
  post         'api/postRequest'
  get          'api/getActivities'

  get          'users/signin'
  get          'users/fbsignin'
  post         'activities/post'
  get          'activities/getsingle'

  resources    :users
  resources    :activities
  
end
