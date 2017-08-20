Rails.application.routes.draw do
  post '/new-dash-session', to: 'tokens#newtoken'

  get '/course-points/:course_id/update', to: 'course_points#update'

  get '/cumulative-points/course/:course_id', to: 'cumulative_points#show'
  # Maybe this should be called skill-mastery?
  get '/skill-percentages/course/:course_id', to: 'mastery_percentages#show'

  get '/leaderboard/course/:course_id', to: 'leaderboards#get_range'
  get '/leaderboard/course/:course_id/all', to: 'leaderboards#get_all'
  get '/leaderboard/course/:course_id/whereis/current', to: 'leaderboards#find_current_user'
  get '/leaderboard/course/:course_id/whereis/:user_id', to: 'leaderboards#find_user'
  get '/leaderboard/course/:course_id/update', to: 'leaderboards#update_points'

  get '/badges', to: 'badges#get_all_badges'

  get '/heatmap/courses/:course_id/all', to: 'heatmaps#everyones_points_average'
  get '/heatmap/courses/:course_id/current-user', to: 'heatmaps#current_user'

end
