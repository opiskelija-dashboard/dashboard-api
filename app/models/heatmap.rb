class Heatmap

	def initialize(course_id, token)
    @point_source = Rails.configuration.points_store_class == 'MockPointsStore' ? MockPointsStore : PointsStore

    @course_id = course_id
    @token = token

    if (!@point_source.has_course_points?(@course_id))
      Rails.logger.debug("PointsStore didn't have points of course " + @course_id + ", fetching...");
      @point_source.update_course_points(@course_id, token)
    end
	end

	def get_everyones_points_average(course_id, token)

		update_points_source_if_necessary(course_id, token)
		everyones_points = PointsHelper.all_course_points(@point_source, course_id)
		points_by_day = PointsHelper.daywise_points(everyones_points)
		unique_users_per_week = PointsHelper.unique_users_per_week(everyones_points)

		daily_average = Hash.new
		points_by_day.each do |day, points|
			week = Date.iso8601(day.to_s).strftime("%G-W%V")
			users_this_week = unique_users_per_week[week].to_f
			Rails.logger.debug("Day " + day.to_s + ", week " + week.to_s + ", points today " + points.to_s + ", users this week " + users_this_week.to_s)
			if (users_this_week == 0)
				avg = 0
			else
				avg = points / users_this_week
			end
			daily_average[day] = avg
		end

		render json: { "data" => daily_average }
	end

	# GET /heatmap/courses/:course_id/current-user
	def get_current_user(course_id, token)
		update_points_source_if_necessary(course_id, token)
		current_users_points = PointsHelper.users_own_points(@point_source, course_id, token.user_id)
		points_by_day = PointsHelper.daywise_points(current_users_points)
		render json: { "data" => points_by_day }
	end

end