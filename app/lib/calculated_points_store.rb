# rubocop:disable Style/ClassVars, Layout/ExtraSpacing, Style/BracesAroundHashParameters, Layout/LineLength, Layout/IndentHash
class CalculatedPointsStore

  @@calculated_points_store = {}
  @@raw_everyones_points = {}
  @@everyones_points_by_day = {}
  @@unique_users_count_by_day = {}
  @@everyones_cumulative_points_by_day = {}
  @@cumulative_unique_users_count_by_day = {}

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
		config = Rails.configuration.points_store_class
		point_source =
      config == 'MockPointsStore' ? MockPointsStore : PointsStore
		everyones_points = PointsHelper.all_course_points(point_source, course_id)
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

	def self.daily_average_for_cumulative(course_id)
    init_all(course_id)
	end
	
  # Initializes data for return:
  # First gets raw_points from PointsStore and then
  # modifies that data for calculation needs
  def self.init_all(course_id)
    init_raw_points(course_id)
    init_daywise_points(course_id)
    init_unique_users_count_by_day(course_id)
    init_cumulative_arrays(course_id)
  end

  # Get raw_points to instance variables
  def self.init_raw_points(course_id)
    config = Rails.configuration.points_store_class
		point_source =
      config == 'MockPointsStore' ? MockPointsStore : PointsStore
    @@raw_everyones_points[course_id] =
      PointsHelper.all_course_points(point_source, course_id)
  end

  # Uses @raw_points and initialize daywise hashes to instance variables
  def self.init_daywise_points(course_id)
    @@everyones_points_by_day[course_id] =
      PointsHelper.daywise_points(@@raw_everyones_points[course_id])
  end

  # Uses @raw_points and initialize hashes of unique users
  # to instance variables
  def self.init_unique_users_count_by_day(course_id)
    all_unique_users = PointsHelper.unique_users_globally(@@raw_everyones_points[course_id])
    @@unique_users_count_by_day[course_id] =
      PointsHelper.new_unique_users_per_day(@@raw_everyones_points[course_id],
                                            all_unique_users)
  end

  # Uses @points_by_day hashes and makes cumulative versions of them
  # to instance variables
  def self.init_cumulative_arrays(course_id)
    @@everyones_cumulative_points_by_day[course_id] =
      PointsHelper.cumulativize(@@everyones_points_by_day[course_id])
    @@cumulative_unique_users_count_by_day[course_id] =
      PointsHelper.cumulativize(@@unique_users_count_by_day[course_id])
  end

  def self.everyones_cumulative_points_by_day(course_id)
    @@everyones_cumulative_points_by_day[course_id]
  end
  
  def self.cumulative_unique_users_count_by_day(course_id)
    @@cumulative_unique_users_count_by_day[course_id]
  end
  
end
