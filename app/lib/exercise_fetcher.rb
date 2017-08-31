class ExerciseFetcher

  def self.fetch_exercises(course_id, jwt_token)
    real_data = Rails.configuration.fetch_real_exercises
    real_data ? real_exercises(course_id, jwt_token) : fake_exercises(course_id)
  end

  def self.real_exercises(course_id, jwt_token)
    endpoint = '/courses/' + course_id + '/exercises'
    Rails.logger.debug("Fetching all exercises from #{endpoint}")
    resp = HttpHelpers.tmc_api_get(endpoint, jwt_token.tmc_token)

    errors = []
    data = []
    if resp[:success]
      Rails.logger.debug('Done fetching')
      data = resp[:body]
      Rails.logger.debug("Exercise data: " + data.inspect);
      success = true
    else
      Rails.logger.debug("Fetch didn't work. Server response: #{resp.inspect}")
      errors.push({
        'title' => "Unable to fetch/update exercises of course #{course_id}",
        'detail' => "Queried #{endpoint}: (#{resp[:code]}) #{resp[:body]}"
                  })
      success = false
    end
    { success: success, errors: errors, data: data }
  end

  def self.fake_exercises(course_id, num_exercises = 30)
    Rails.logger.debug("Creating fake exercises for course #{course_id}")
    exercises = []
    i = 1
    while i <= num_exercises
      exercise_time = Time.now # you can do fancy shit here if you wish
      ex = fakex(i, nil, exercise_time, false, 1)
      exercises.push(ex)
      i += 1
    end
    # Any hard-coded exercises you want you can put here
    # ex = {...} ; exercises.push(ex)

    { success: true, errors: [], data: exercises }
  end

  private

  def fakex(id, name = nil, publ_time = 1,
                 disabled = false, point_count = 1)
    six_digit_hex_string = '%06x' % Random.rand(65536 * 256)
    name = six_digit_hex_string.upcase if name.nil?
    one_week = 7 * 86_400 # seconds

    # generate fake points
    avail_pts = []
    i = 1
    while i <= point_count
      pt = {
        'id' => Random.rand(1000..100_000),
        'exercise_id' => id,
        'name' => '%02d_%02d' % [id, i],
        'require_review' => false
      }
      avail_pts.push(pt)
      i += 1
    end

    # The fake exercise itself.
    {
      'id' => id,
      'name' => name,
      'publish_time' => Time.at(publ_time).to_datetime,
      'solution_visible_after' => Time.at(publ_time + one_week).to_datetime,
      'deadline' => Time.at(publ_time + one_week).to_datetime,
      'disabled' => disabled,
      'available_points' => avail_pts
    }
  end
end
