Rails.application.routes.draw do

  get '/cumulative-points', to: 'users#demo'

  #get '/api/v8/courses/:course_id/users/current/points', to: ''

  post '/new-dash-session', to: 'tokens#newtoken'

end
