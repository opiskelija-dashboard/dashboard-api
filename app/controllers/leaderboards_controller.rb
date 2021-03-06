# rubocop:disable Metrics/LineLength
# (There are many render lines with long error messages; individually
#  turning this off for each of them is messy.)
class LeaderboardsController < ApplicationController
  # rubocop:disable Style/ClassVars
  # We have a reason to use this: caching of big data sets
  # and this is cleaner than another singleton class, IMO.
  @@leaderboards = {}
  # rubocop:enable Style/ClassVars

  def initialize
    # Typically, point_source would be PointsStore, but for testing purposes
    # you might want to use MockPointsStore.
    config = Rails.configuration.points_store_class
    @point_source =
    config == 'MockPointsStore' ? MockPointsStore : PointsStore
  end

  # GET /leaderboard/course/:course_id?from=:from&to=:to
  def get_range
    course_id = params['course_id']
    from = params['from'].nil? ? 1 : params['from'].to_i
    to = params['to'].nil? ? 10 : params['to'].to_i
    Rails.logger.debug("from: #{from}\tto: #{to}")
    # TODO: check that `from` and `to` are numbers and that `from` <= `to`

    leaderboard = @@leaderboards[course_id]
    if leaderboard.nil? || leaderboard.empty?
      if recalculate_empty_leaderboard(course_id)
        get_range # recurse
        return # So we don't continue execution with empty data.
      else
        render json: { data: [] }, status: 204 # No Content
        return
      end
    end

    interesting_subset = []
    i = from
    while i <= to
      array_index = i - 1 # because humans don't start indexing from zero
      interesting_subset.push(leaderboard[array_index])
      i += 1
    end

    render json: { data: interesting_subset }
  end

  # GET /leaderboard/course/:course_id/all
  def get_all
    course_id = params['course_id']

    leaderboard = @@leaderboards[course_id]
    if leaderboard.nil?
      if recalculate_empty_leaderboard(course_id)
        get_all
      else
        render json: { data: [] }, status: 204 # No Content
        return
      end
    else
      render json: { data: leaderboard }, status: 200 # OK
      return
    end
  end

  # GET /leaderboard/course/:course_id/whereis/:user_id
  def find_user
    # rubocop:disable Style/IdenticalConditionalBranches
    # Rails is a bitch when it comes to render statements and returning.
    course_id = params['course_id']
    user_id = params['user_id']

    leaderboard = @@leaderboards[course_id]
    if leaderboard.nil?
      if recalculate_empty_leaderboard(course_id)
        find_user
      else
        render json: { data: "not found: user_id #{user_id} is not in course_id #{course_id} because course is empty" }, status: 404 # Not Found
        return
      end
    end

    searched_for = nil
    leaderboard.each do |a|
      if a['user_id'].to_s == user_id.to_s
        searched_for = a
        break
      end
    end

    if searched_for.nil?
      render json: { data: "not found: user_id #{user_id} is not in course_id #{course_id}" }, status: 404 # Not Found
    else
      render json: { data: [searched_for] }
    end
    # rubocop:enable Style/IdenticalConditionalBranches
  end

  # GET /leaderboard/course/:courseid/whereis/current
  def find_current_user
    # User ID of the current user is passed around in the JWT token
    params['user_id'] = @token.user_id.to_s
    # Pass responsibility of finding the user to the other method.
    find_user
  end

  private

  def recalculate_empty_leaderboard(course_id)
    Rails.logger.debug("@@leaderboards[#{course_id.inspect}]: attempting recalculation")

    course_points = @point_source.course_points_update_if_necessary(course_id, @token)

    if course_points.nil? || course_points.empty?
      Rails.logger.debug("Couldn't recalculate @@leaderboards[#{course_id.inspect}] as there is no point data in the point store")
      return false
    else
      leaderboard = calculate_leaderboard(course_points)
      @@leaderboards[course_id] = leaderboard
      Rails.logger.debug("Recalculated @@leaderboards[#{course_id.inspect}]")
      return true
    end
  end

  def calculate_leaderboard(raw_course_points)
    # Format of raw_user_points elements:
    # { 'exercise_id' => 33235,
    #   'awarded_point' => {
    #     'name' => '01-06',
    #     'submission_id' => 1062559,
    #     'course_id' => 214,
    #     'id' => 1273255,
    #     'user_id' => 12057,
    #     'created_at' => '2017-08-10T15:03:05+0300'
    # }}
    points_per_user = {}
    raw_course_points.each do |h|
      ap = h['awarded_point']
      user_id = ap['user_id']

      points_per_user[user_id] = 0 if points_per_user[user_id].nil?

      points_per_user[user_id] += 1
    end

    # We want to transform our hash: { user1 => 4000, user2 => 3013, ...}
    # into an array of arrays: [ [4000, user1], [3013, user2], ...]
    # This is because Array#<=> does a columnwise comparison: when doing
    # [4000, user1] <=> [5913, user3], the first step is 4000 <=> 5913.
    point_user_tuples = []
    points_per_user.each do |k, v|
      tuple = [v, k]
      point_user_tuples.push(tuple)
    end
    point_user_tuples.sort! # sorts lowest points first
    point_user_tuples.reverse! # make highest points first
    # Side effect: ranking of those with equal points is determined by user ID.

    # Now we transform our array of tuples into an array of hashes.
    max = point_user_tuples.length
    i = 0
    leaderboard = []
    while i < max
      j = i + 1
      tuple = point_user_tuples[i]
      leaderboard_row = { index: j, points: tuple[0], user_id: tuple[1] }
      leaderboard.push(leaderboard_row)
      i += 1
    end

    leaderboard
  end
end
