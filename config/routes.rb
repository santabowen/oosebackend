Rails.application.routes.draw do

  get 'sessions/new'

  root         'home#index'
  get          'api/changeLogo'
  post         'api/postRequest'
  get          'api/getActivities'

  get          'users/signin'
  post         'activities/post'
  get          'activities/get'

  resources    :users
  resources    :activities
  
end
