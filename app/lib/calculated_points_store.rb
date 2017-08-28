# rubocop:disable Style/ClassVars, Layout/ExtraSpacing, Style/BracesAroundHashParameters, Layout/LineLength, Layout/IndentHash
class CalculatedPointsStore

  @@calculated_points_store = {}

	def self.update_calculated_course_points(course_id)
		errors = []
		course_id = course_id.to_s
		@@calculated_points_store[course_id] = everyones_points_average(course_id)
	end

	def self.daily_average_for_heatmap(course_id)
		@@calculated_points_store[course_id]
	end

	# GET /heatmap/courses/:course_id/all
	# OUTPUT hash {'date': 'everyones_average_points'}
	def self.everyones_points_average(course_id)
		everyones_points = PointsHelper.all_course_points(PointsStore, course_id)
		points_by_day = PointsHelper.daywise_points(everyones_points)
		unique_users_by_week = PointsHelper.unique_users_by_week(everyones_points)
		daily_average = {}
		points_by_day.each do |day, points|
			week = Date.iso8601(day.to_s).strftime('%G-W%V')
			users_this_week = unique_users_by_week[week].to_f
			avg = if users_this_week.zero?
							0
						else
							points / users_this_week
						end
			daily_average[day] = avg.round(0)
		end
		daily_average
	end
	
end
