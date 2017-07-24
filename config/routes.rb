Rails.application.routes.draw do
  resources :points

  get '/total_points', to: 'points#total_points'
  #get '/api/v8/courses/:course_id/users/current/points', to: ''
end
