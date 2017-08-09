class LeaderboardsController < ApplicationController

  @@leaderboards = Hash.new

  # GET /leaderboards/course/:course_id?from=:from&to=:to
  def get_range
    course_id = params["course_id"]
    from = params["from"].nil? ? 1 : params["from"].to_i
    to = params["to"].nil? ? 10 : params["to"].to_i
    Rails.logger.debug("from: #{from}\tto: #{to}")
    # TODO: check that `from` and `to` are numbers and that `from` <= `to`

    leaderboard = @@leaderboards[course_id]
    if (leaderboard.nil?)
      Rails.logger.debug("@@leaderboards[" + course_id.inspect + "] was nil")
      render json: {"data" => []}
      return
    end

    interesting_subset = Array.new
    i = from
    while i <= to do
      array_index = i-1 # because humans don't start indexing from zero
      interesting_subset.push(leaderboard[array_index])
      i += 1
    end

    render json: { "data" => interesting_subset }
  end

  # GET /leaderboards/course/:course_id/all
  def get_all
    course_id = params["course_id"]

    leaderboard = @@leaderboards[course_id]
    if (leaderboard.nil?)
      Rails.logger.debug("@@leaderboards[" + course_id.inspect + "] was nil")
      render json: {"data" => []}
      return
    else
      render json: {"data" => leaderboard}
      return
    end
  end

  # GET /leaderbaords/course/:course_id/whereis/:user_id
  def find_user
    course_id = params["course_id"]
    user_id = params["user_id"]

    leaderboard = @@leaderboards[course_id]
    if (leaderboard.nil?)
      Rails.logger.debug("@@leaderboards[" + course_id.inspect + "] was nil")
      render json: {"data" => "not found: user_id " + user_id + " is not in course_id " + course_id }
      return
    end

    searched_for = nil
    leaderboard.each do |a|
      if (a["user_id"].to_s == user_id.to_s)
        searched_for = a
        break
      end
    end

    if (searched_for.nil?)
      render json: {"data" => "not found: user_id " + user_id + " is not in course_id " + course_id }
      return
    else
      render json: {"data" => [searched_for]}
      return
    end
  end

  def update_points
    course_id = params[:course_id].to_s

    if (!PointsStore.course_point_update_needed?(course_id))
      render json: { "data" => "Points of course " + course_id + " not updated because data isn't too old yet" }, status: 200 #ok
      return
    end

    update_attempt = PointsStore.update_course_points(course_id, @token)

    if (update_attempt[:success])
      course_points = PointsStore.course_points(course_id)
      leaderboard = calculate_leaderboard(course_points)
      @@leaderboards[course_id] = leaderboard
      render json: { "data" => "OK, updated points of course " + course_id }, status: 200
    else
      errors = update_attempt[:errors]
      errors.push({
        "title" => "Unable to update leaderboard for course " + course_id,
        "detail" => "The update failed at the course-point-updating stage."
      });
      render json: { "errors" => errors }, status: 500 #server error
    end
  end

  private

  def calculate_leaderboard(raw_course_points)
    # Format of raw_user_points elements:
    # { 'exercise_id' => 33235,
    #   'awarded_point' => {
    #     'name' => '01-06',
    #     'submission_id' => 1062559,
    #     'course_id' => 214,
    #     'id' => 1273255,
    #     'user_id' => 12057
    # }}
    points_per_user = Hash.new
    raw_course_points.each do |h|
      exercise_id = h["exercise_id"]
      ap = h["awarded_point"]
      user_id = ap["user_id"]

      if (points_per_user[user_id].nil?)
        points_per_user[user_id] = 0
      end

      points_per_user[user_id] += 1
    end

    # We want to transform our hash: { user1 => 4000, user2 => 3013, ...}
    # into an array of arrays: [ [4000, user1], [3013, user2], ...]
    # This is because Array#<=> does a columnwise comparison: when doing
    # [4000, user1] <=> [5913, user3], the first step is 4000 <=> 5913.
    point_user_tuples = Array.new
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
    leaderboard = Array.new
    while (i < max) do
      j = i + 1
      tuple = point_user_tuples[i]
      leaderboard_row = { "index" => j, "points" => tuple[0], "user_id" => tuple[1]}
      leaderboard.push(leaderboard_row)
      i += 1
    end

    return leaderboard
  end

end
