# rubocop:disable Style/ClassVars, Layout/ExtraSpacing, Style/BracesAroundHashParameters, Layout/LineLength, Layout/IndentHash
class PointsStore
  # Format of raw_user_points elements:
  # { 'exercise_id' => 33235,
  #   'awarded_point' => {
  #     'name' => '01-06',
  #     'submission_id' => 1062559,
  #     'course_id' => 214,
  #     'id' => 1273255,
  #     'user_id' => 12057
  #     'created_at' => '2017-08-10T15:03:05+0300'
  # }}

  @@points_store = {}
  @@update_times = {}  # update times by course id
  UPDATE_INTERVAL = Rails.configuration.points_store_update_interval  # seconds

  def self.has_course_points?(course_id)
    course_points = @@points_store[course_id.to_s]
    !course_points.nil?
  end

  def self.course_points(course_id)
    course_id = course_id.to_s
    @@points_store[course_id]
  end

  def self.course_point_update_needed?(course_id)
    update_time = @@update_times[course_id.to_s]
    update_time = Time.at(0) if update_time.nil?
    t = update_time + UPDATE_INTERVAL # Earliest time an update is necessary
    (t <=> Time.new) <= 0
  end

  # Returns a hash:
  # { success: true/false,
  #   errors: [ {"title" => ..., "detail" => ...} ]
  # } with the "errors" array being non-empty if there were errors fetching
  # the data. Data is then available using other PointsStore methods.
  def self.update_course_points(course_id, jwt_token)
    errors = []
    course_id = course_id.to_s

    endpoint = '/courses/' + course_id + '/points'
    Rails.logger.debug("Fetching all points from #{endpoint}, this may take a while")
    resp = HttpHelpers.tmc_api_get(endpoint, jwt_token.tmc_token)

    if resp[:success]
      Rails.logger.debug('Done fetching')
      @@points_store[course_id] = resp[:body]
      @@update_times[course_id] = Time.new
      CalculatedPointsStore.update_calculated_course_points(course_id)
      CalculatedPointsStore.init_all(course_id)
      success = true
    else
      Rails.logger.debug("Fetch didn't work. Server response: #{resp.inspect}")
      errors.push({
        'title' => "Unable to fetch/update points of course #{course_id}",
        'detail' => "Queried #{endpoint}: (#{resp[:code]}) #{resp[:body]}"
      })
      success = false
    end
    { success: success, errors: errors }
  end

  # For use by BadgeHelper and BadgeCalcController.
  def self.all_points
    @@points_store
  end
end
