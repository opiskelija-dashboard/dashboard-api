Rails.application.routes.draw do

  resources :points

  get '/total_points', to: 'points#total_points'
  #get '/api/v8/courses/:course_id/users/current/points', to: ''

  resources :sessions, only: [] # [:show, :new, :create, :update, :destroy]
  get '/session', to: 'sessions#show'
  put '/settoken', to: 'sessions#set_tmc_access_token'

end
