Rails.application.routes.draw do

  resources :points

  get '/total_points', to: 'points#total_points'
  #get '/api/v8/courses/:course_id/users/current/points', to: ''

  post '/new-dash-session', to: 'token#newtoken'
  #put '/settoken', to: 'sessions#set_tmc_access_token'

end
