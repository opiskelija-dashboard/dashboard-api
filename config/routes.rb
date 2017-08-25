# rubocop:disable Metrics/LineLength, Metrics/BlockLength
Rails.application.routes.draw do
  post '/new-dash-session', to: 'tokens#newtoken'
  get '/is-admin', to: 'admin#is_admin'

  get '/course-points/:course_id/update', to: 'course_points#update'

  get '/cumulative-points/course/:course_id', to: 'cumulative_points#show'
  # Maybe this should be called skill-mastery?
  get '/skill-percentages/course/:course_id', to: 'mastery_percentages#show'

  get '/leaderboard/course/:course_id', to: 'leaderboards#get_range'
  get '/leaderboard/course/:course_id/all', to: 'leaderboards#get_all'
  get '/leaderboard/course/:course_id/whereis/current', to: 'leaderboards#find_current_user'
  get '/leaderboard/course/:course_id/whereis/:user_id', to: 'leaderboards#find_user'
  get '/leaderboard/course/:course_id/update', to: 'leaderboards#update_points'

  get '/heatmap/courses/:course_id/all', to: 'heatmaps#get_all'
  get '/heatmap/courses/:course_id/current-user', to: 'heatmaps#get_current_user'

  get '/user-badges/course/:course_id/earned', to: 'badges#earned_in_course'
  get '/user-badges/course/:course_id/unearned', to: 'badges#unearned_in_course'
  get '/user-badges/global/earned', to: 'badges#earned_global'
  get '/user-badges/global/unearned', to: 'badges#unearned_global'

  get '/calc-user-badges/course/:course_id', to: 'badge_calc#calc_user'
  get '/calc-user-badges/global', to: 'badge_calc#calc_global'

  get '/badge-admin/badgedef/all', to: 'badge_admin#all_badgedefs'
  get '/badge-admin/badgedef/:badgedef_id', to: 'badge_admin#one_badgedef'
  get '/badge-admin/badgecode/all', to: 'badge_admin#all_badgecodes'
  get '/badge-admin/badgecode/:badgecode_id', to: 'badge_admin#one_badgecode'
  post '/badge-admin/badgedef', to: 'badge_admin#new_badgedef'
  post '/badge-admin/badgecode', to: 'badge_admin#new_codedef'
  put '/badge-admin/badgedef/:badgedef_id', to: 'badge_admin#update_badgedef'
  put '/badge-admin/badgecode/:badgecode_id', to: 'badge_admin#update_badgecode'
  delete '/badge-admin/badgedef/:badgedef_id', to: 'badge_admin#delete_badgedef'
  delete '/badge-admin/badgecode/:badgecode_id', to: 'badge_admin#delete_badgecode'
end
