class User < ApplicationRecord
  validates :id, uniqueness: true

  # Creates an array of all the points of the user.
  def set_points
    user_points = []

    url = 'http://secure-wave-81252.herokuapp.com/points'
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    hash = JSON.parse response.body
    hash.each do |point|
      user_points << Point.new(point['awarded_point']['id'], point['awarded_point']['submission_id'])
    end
    user_points
  end

  # Creates a hash of all the submissions of the user.
  def set_submissions
    user_submissions = {}

    url = 'http://secure-wave-81252.herokuapp.com/submissions'
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    hash = JSON.parse response.body

    hash.each do |submission|
      sub = Submission.new(submission['id'], submission['created_at'])
      user_submissions[sub.getId] = sub
    end
    user_submissions
  end

  # Creates an array to render as 'days' (Check: UserSerializer in serializers).
  def set_hash_for_days_and_points
    user_points = set_points
    user_submissions = set_submissions
    days = []

    user_points.each do |user_point|
      days << user_submissions[user_point.getSubmissionId].getCreatedAt.to_date
    end
    days = days.sort

    # Change these to correspond to the correct TMC API earliest and latest submissions.
    earliest_day = days.first

    hash = {}

    begin
      hash["#{earliest_day}"] = 0
      earliest_day += 1
    end until earliest_day > days.last

    i = 0

    begin
      hash["#{days[i]}"] = hash["#{days[i]}"] + 1
      i += 1
    end until i == days.count

    hash
  end

  def days
    set_hash_for_days_and_points.keys
  end

  # Creates an array to render as 'points' (Check: UserSerializer in serializers).
  def points
    hash = set_hash_for_days_and_points
    i = 1
    points = []
    points[0] = hash.values[0]

    begin
      points[i] = points[i - 1] + hash.values[i]
      i += 1
    end until i == hash.length

    points
  end
end
