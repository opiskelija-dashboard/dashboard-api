Rails.application.routes.draw do
  post '/new-dash-session', to: 'tokens#newtoken'

  get '/cumulative-points/course/:course_id', to: 'cumulative_points#show'
  get '/skill-percentages/course/:course_id', to: 'mastery_percentages#skill_percentage_current'

  get '/leaderboard/course/:course_id', to: 'leaderboards#get_range'
  get '/leaderboard/course/:course_id/all', to: 'leaderboards#get_all'
  get '/leaderboard/course/:course_id/whereis/current', to: 'leaderboards#find_current_user'
  get '/leaderboard/course/:course_id/whereis/:user_id', to: 'leaderboards#find_user'
  get '/leaderboard/course/:course_id/update', to: 'leaderboards#update_points'


end
