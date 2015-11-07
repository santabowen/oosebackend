Rails.application.routes.draw do

  get 'sessions/new'

  root         'home#index'
  get          'api/changeLogo'
  post         'api/postRequest'
  get          'api/getActivities'

  resources    :users
  
end
