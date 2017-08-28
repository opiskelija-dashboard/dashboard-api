# A mock PointsStore with fake data but no calls to external APIs
class MockPointsStore
  require 'date'

  # Format of raw_user_points elements:
  # { 'exercise_id' => 33235,
  #   'awarded_point' => {
  #     'name' => '01-06',
  #     'submission_id' => 1062559,
  #     'course_id' => 214,
  #     'id' => 1273255,
  #     'user_id' => 12057
  #     # pending a pull request:
  #     'created_at' => '2017-08-10T15:03:05+0300'
  # }}

  @fake_points = {}
  @update_times = {} # update times by course id
  UPDATE_INTERVAL = Rails.configuration.points_store_update_interval # seconds

  # Return false if the course's points haven't been "updated" yet.
  def self.has_course_points?(course_id)
    cid = course_id.to_s
    if @fake_points[cid].nil?
      @fake_points[cid] = []
      return false
    end
    true
  end

  def self.course_points(course_id)
    course_id = course_id.to_s
    @fake_points[course_id]
  end

  def self.course_point_update_needed?(course_id)
    update_time = @update_times[course_id.to_s]
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

    if jwt_token.valid?
      success = true
      @update_times[course_id] = Time.new
      @fake_points[course_id] = generate_fake_points(course_id)
    else
      success = false
      # rubocop:disable Metrics/LineLength
      error = {
        'title' => "Unable to fetch/update points of course #{course_id}",
        'detail' => 'This is the MockPointsStore, but you still need to give a valid (altho not necessarily tested) JWT token.'
      }
      # rubocop:enable Metrics/LineLength
      errors.push(error)
    end
    { success: success, errors: errors }
  end

  # Like the normal update_course_points, but doesn't need a valid JWT token.
  # This is for use by BadgeHelper, which uses fake course data to test for
  # syntax errors.
  def self.force_update_course_points(course_id)
    course_id = course_id.to_s
    @update_times[course_id] = Time.new
    @fake_points[course_id] = generate_fake_points(course_id)
  end

  # Also for use by BadgeHelper.
  def self.all_points
    @fake_points
  end

  private

  # rubocop:disable Metrics/CyclomaticComplexity
  # This is just a laundry list method, no use in breaking it up
  # and spreading it out.
  def self.generate_fake_points(course_id)
    today = Time.now.to_date
    course_start_time = (today - (4 * 7)).to_time.to_i # Date#- subtracts days.
    # course_end_time = (today + (2 * 7)).to_time.to_i # Date#+ adds days.

    fake_users = []
    users_to_have_in_this_course = Random.rand(2..200)
    while users_to_have_in_this_course > 0
      fake_user_id = random_id_from_range(200, 2000)
      fake_users.push(fake_user_id)
      users_to_have_in_this_course -= 1
    end

    fake_point_names = []
    weeks = 6
    while weeks > 0
      points_this_week = Random.rand(4..16)
      while points_this_week > 0
        point_name = format('%02d_%02d', weeks, points_this_week)
        fake_point_names.push(point_name)
        points_this_week -= 1
      end
      weeks -= 1
    end

    fake_exercise_ids = []
    exercise_ids_to_generate = fake_point_names.length
    while exercise_ids_to_generate > 0
      exid = random_id_from_range(1000, 100_000)
      fake_exercise_ids.push(exid)
      exercise_ids_to_generate -= 1
    end

    fake_points = []
    t = course_start_time
    sqrt_users = fake_users.length**0.5
    sqrt_points = fake_points.length**0.5
    max_points_per_day = (sqrt_users * sqrt_points).ceil + 1
    while t <= today.to_time.to_i
      points_to_award_today = Random.rand(0..max_points_per_day)
      while points_to_award_today > 0
        user_id = fake_users[Random.rand(0...fake_users.length)]
        submission_id = random_id_from_range(10_000, 90_000)
        point_id = random_id_from_range(10_000, 200_000)
        randindex = Random.rand(0...fake_exercise_ids.length)
        exercise_id = fake_exercise_ids[randindex]
        point_name = fake_point_names[randindex]
        random_time_today = Time.at(t + Random.rand(1...86_399)).to_datetime

        point = fake_point(exercise_id, point_name, submission_id,
                           course_id.to_i, point_id, user_id, random_time_today)
        fake_points.push(point)

        points_to_award_today -= 1
      end
      t += 86_400 # one day
    end

    fake_point_date = DateTime.new(2007, 1, 1, 12, 0, 0, '+3')
    guaranteed_fake_point = fake_point(997, '01_20', 998, course_id, 999, 2,
                                       fake_point_date)
    # The guaranteed fake point:
    # {'exercise_id'=>997, 'awarded_point' => {
    #    'name'=>'01_20', 'submission_id'=>998, 'course_id'=> course_id,
    #    'id'=>999, 'user_id'=>2, 'created_at'=>'2007-01-01T12:00:00+0300'
    # } }
    fake_points.push(guaranteed_fake_point)

    fake_points
  end

  # rubocop:disable Metrics/ParameterLists
  def self.fake_point(exercise_id, point_name, submission_id, course_id, point_id,
                 user_id, created_at)
    # %FT%T%z = YYYY-mm-dd + literal "T" + HH:MM:SS + "+/-"HHMM timezone
    timestr = created_at.strftime('%FT%T%z')
    {
      'exercise_id' => exercise_id,
      'awarded_point' => {
        'name' => point_name,
        'submission_id' => submission_id,
        'course_id' => course_id,
        'id' => point_id,
        'user_id' => user_id,
        'created_at' => timestr
      }
    }
  end

  def self.random_id_from_range(min, max)
    Random.rand(min..max)
  end
end
