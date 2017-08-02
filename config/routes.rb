Rails.application.routes.draw do

  get '/cumulative-points', to: 'cumulative_points#cumulative_point_current'

  #get '/api/v8/courses/:course_id/users/current/points', to: ''

  post '/new-dash-session', to: 'tokens#newtoken'

end
