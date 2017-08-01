class SubmissionsController < ApplicationController
  before_action :set_submissions

  # GET /submissions
  def index
    render json: Submission.first
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_submissions
    url = "http://secure-wave-81252.herokuapp.com/submissions"
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
  end

  # Only allow a trusted parameter "white list" through.
  def submission_params
    params.require(:submission).permit(:submission_id, :user_id, :pretest_error, :created_at, :updated_at,
                                       :exercise_name, :course_id, :processed, :all_tests_passed, :processing_tried_at,
                                       :processing_began_at, :processing_completed_at, :times_sent_to_sandbox,
                                       :processing_attempts_started_at, :params_json, :requires_review, :requests_review,
                                       :reviewed, :message_for_reviewer, :newer_submission_reviewed, :review_dismissed,
                                       :paste_available, :message_for_paste, :paste_key)
  end
end
