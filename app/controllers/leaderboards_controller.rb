class LeaderboardsController < ApplicationController

  @@raw_points = Hash.new
  @@leaderboards = Hash.new

  # GET /leaderboards/course/:course_id?from=:from&to=:to
  def get_range
    course_id = params["course_id"]
    from = params["from"]
    to = params["to"]
    # TODO: check that `from` and `to` are numbers and that `from` <= `to`
    if (from.nil?)
      from = 1
    else
      from = from.to_i
    end
    if (to.nil?)
      to = 10
    else
      to = to.to_i
    end

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
      render json: {"data" => []}
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
    course_id = params[:course_id]

    endpoint = '/courses/' + course_id.to_s + '/points'
    Rails.logger.debug("Fetching all points from " + endpoint + ", this may take a while")
    response = HttpHelpers.tmc_api_get(endpoint, @token.tmc_token)

    if (response[:success])
      Rails.logger.debug("Done fetching")
      @@raw_points[course_id.to_s] = response[:body]
      calculate_leaderboard(course_id)
      render json: { "data" => 'Fetched ' + course_id.to_s + ' OK' }
      return
    else
      Rails.logger.debug("Fetch didn't work; the response object: " + response.inspect)
      render json: { "errors" =>
        [{
          "title" => "Unable to update leaderboard for course " + course_id.to_s,
          "detail" => "Response from the TMC server: " + response.inspect
        }]
      }, status: 500
      return
    end
  end

  private

  def calculate_leaderboard(course_id)
    raw = @@raw_points[course_id]
    if (raw.nil?)
      Rails.logger.debug("calculate_leaderboard(" + course_id.inspect + ") called, nothing in @@raw_points[" + course_id.inspect + "]")
      return
    end

    output = ""

    points_per_user = Hash.new
    #{ 'exercise_id' => 33235,
    #  'awarded_point' => {
    #    'name' => '01-06',
    #    'submission_id' => 1062559,
    #    'course_id' => 214,
    #    'id' => 1273255,
    #    'user_id' => 12057
    #} }
    raw.each do |h|
      exercise_id = h["exercise_id"]
      ap = h["awarded_point"]
      user_id = ap["user_id"]

      if (points_per_user[user_id].nil?)
        points_per_user[user_id] = 0
      end

      points_per_user[user_id] += 1
    end

    #output += points_per_user.inspect
    #output += "\n\n"

    # We want to transform our hash: { user1 => 4000, user2 => 3013, user3 => 5913, ...}
    # into an array of arrays: [ [4000, user1], [3013, user2], [5913, user3], ...]
    # This is because Array#<=> does a columnwise comparison: when doing
    # [4000, user1] <=> [5913, user3], the first step is 4000 <=> 5913.
    point_user_tuples = Array.new
    points_per_user.each do |k, v|
      tuple = [v, k]
      point_user_tuples.push(tuple)
    end
    point_user_tuples.sort! # sorts lowest points first
    point_user_tuples.reverse! # make highest points first

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

    @@leaderboards[course_id.to_s] = leaderboard
  end

end
