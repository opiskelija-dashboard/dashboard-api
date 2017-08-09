class PointsStore

  @@points_store = Hash.new
  @@update_times = Hash.new  # update times by course id
  UPDATE_INTERVAL = Rails.configuration.points_store_update_interval  # seconds

  # def initialize
  #   if ($global_points_store.nil?)
  #     Rails.logger.debug("fffffffffffff $global_points_store was nil");
  #     $global_points_store = Hash.new
  #   end
  # end

  def self.has_course_points?(course_id)
    course_points = @@points_store[course_id.to_s]
    return !course_points.nil?
  end

  def self.course_points(course_id)
    course_id = course_id.to_s
    points = @@points_store[course_id]
    return points
  end

  def self.course_point_update_needed?(course_id)
    update_time = @@update_times[course_id.to_s]
    update_time = Time.at(0) if (update_time.nil?)
    t = update_time + UPDATE_INTERVAL  # Earliest time an update is necessary
    return (t <=> Time.new) <= 0
  end


  # Returns a hash:
  # { success: true/false,
  #   errors: [ {"title" => ...,̣ "detail" => ...} ]
  # } with the "errors" array being non-empty if there were errors fetching
  # the data. Data is then available using other PointsStore methods.
  def self.update_course_points(course_id, jwt_token)
    errors = Array.new
    course_id = course_id.to_s

    endpoint = '/courses/' + course_id + '/points'
    Rails.logger.debug("Fetching all points from " + endpoint + ", this may take a while")
    response = HttpHelpers.tmc_api_get(endpoint, jwt_token.tmc_token)

    if (response[:success])
      Rails.logger.debug("Done fetching")
      @@points_store[course_id] = response[:body]
      @@update_times[course_id] = Time.new
      success = true
    else
      Rails.logger.debug("Fetch didn't work; the response object: " + response.inspect)
      errors.push({
        "title" => "Unable to fetch/update points of course " + course_id,
        "detail" => "Queried " + endpoint + ": (" + response[:code] + ") " + response[:body]
      })
      success = false
    end
    return { success: success, errors: errors }
  end

end
