module ApplicationHelper
  def setUpDatabase
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    hash = JSON.parse response.body
    hash.each do |submission|
      s = Submission.new
      s.submission_id = submission['id']
      s.user_id = submission['user_id']
      s.pretest_error = submission['pretest_error']
      s.created_at = submission['created_at']
      s.updated_at = submission['updated_at']
      s.exercise_name = submission['exercise_name']
      s.course_id = submission['course_id']
      s.processed = submission['processed']
      s.all_tests_passed = submission['all_tests_passed']
      s.points = submission['points']
      s.processing_tried_at = submission['processing_tried_at']
      s.processing_began_at = submission['processing_began_at']
      s.processing_completed_at = submission['processing_completed_at']
      s.times_sent_to_sandbox = submission['times_sent_to_sandbox']
      s.processing_attempts_started_at = submission['processing_attempts_started_at']
      s.params_json = submission['params_json']
      s.requires_review = submission['requires_review']
      s.requests_review = submission['requests_review']
      s.reviewed = submission['reviewed']
      s.message_for_reviewer = submission['message_for_reviewer']
      s.newer_submission_reviewed = submission['newer_submission_reviewed']
      s.review_dismissed = submission['review_dismissed']
      s.paste_available = submission['paste_available']
      s.message_for_paste = submission['message_for_paste']
      s.paste_key = submission['paste_key']
      s.save
    end

    url = 'http://secure-wave-81252.herokuapp.com/points'
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    hash = JSON.parse response.body
    hash.each do |point|
      p = Point.new
      p.exercise_id = point['exercise_id']
      p.point_id = point['awarded_point']['id']
      p.course_id = point['awarded_point']['course_id']
      p.user_id = point['awarded_point']['user_id']
      p.submission_id = point['awarded_point']['submission_id']
      p.name = point['awarded_point']['name']
      p.save
    end
  end
end
