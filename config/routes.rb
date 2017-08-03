Rails.application.routes.draw do
  get '/cumulative-points', to: 'cumulative_points#cumulative_point_current'
  get '/skill-percentage', to: 'mastery_percentages#skill_percentage_current'
  post '/new-dash-session', to: 'tokens#newtoken'
end
