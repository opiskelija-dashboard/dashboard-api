class CumulativePoint
  include ActiveModel::Serializers::JSON

  #URLS - Change these to the correct ones when possible.
  CURRENT_USER_POINTS_ENDPOINT = '/api/v8/courses/:course_id/users/current/points'
  ALL_USER_POINTS_ENDPOINT = '/api/v8/courses/:course_id/points'
  CURRENT_USER_SUBMISSIONS_ENDPOINT = '/api/v8/courses/:course_id/users/current/submissions'
  # set this from config/application.rb
  API_BASE_ADDRESS = 'http://secure-wave-81252.herokuapp.com'

  def initialize(token)
    @token = token
  end

  # Returns an array of all points of user(s) and all user ids from url.
  def get_points(endpoint)
    points = []
    user_ids = {}

    # without the API_BASE_ADDRESS this will use Rails.configuration.tmc_api_base_address,
    # like everything should
    response = HttpHelpers.tmc_api_get(endpoint, @token.tmc_token, API_BASE_ADDRESS)
    # This really should also check response[:success] before continuing

    response[:body].each do |point|
      points << Point.new(point['awarded_point']['id'], point['awarded_point']['submission_id'])
      user_ids[point['awarded_point']['user_id']] = 0
    end

    points_user_ids = []
    points_user_ids << points
    points_user_ids << user_ids
  end

  def user_points
    get_points(CURRENT_USER_POINTS_ENDPOINT)
  end

  def all_points
    get_points(ALL_USER_POINTS_ENDPOINT)
  end

  # Creates a hash of all the submissions of the user.
  def get_submissions
    submissions = {}

    # without the API_BASE_ADDRESS this will use Rails.configuration.tmc_api_base_address,
    # like everything should
    response = HttpHelpers.tmc_api_get(endpoint, @token.tmc_token, API_BASE_ADDRESS)
    # This really should also check response[:success] before continuing

    response[:body].each do |submission|
      sub = Submission.new(submission['id'], submission['created_at'])
      submissions[sub.id] = sub
    end
    submissions
  end

  # Returns hash: keys = days, values = points
  def hash_for_days_and_points
    points = user_points[0]
    submissions = get_submissions

    # Adds every submissions created_at to an array and sorts it.
    days = []
    points.each do |point|
      days << submissions[point.submission_id].created_at.to_date
    end
    days = days.sort

    # Change these to correspond to the correct TMC API earliest and latest submissions.
    day = days.first

    # Sets a hash with dates from first to last submission dates.
    hash = {}
    begin
      hash["#{day}"] = 0
      day += 1
    end until day > days.last

    # Adds the amount of submissions made to each day.
    i = 0
    begin
      hash["#{days[i]}"] = hash["#{days[i]}"] + 1
      i += 1
    end until i == days.count

    hash
  end

  # Returns days of the hash_for_days_and_points hash.
  def days
    hash_for_days_and_points.keys
  end

  # Returns points
  def points
    hash = hash_for_days_and_points

    points = []
    points[0] = hash.values[0]

    # Makes cumulative array of points from hash_for_days_and_points hash.
    i = 1
    begin
      points[i] = points[i - 1] + hash.values[i]
      i += 1
    end until i == hash.length

    points
  end

  def average
    points_and_users = all_points
    (all_points[0].count / all_points[1].count.to_f).round(2)
  end
end
