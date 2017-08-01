class CreateSubmissions < ActiveRecord::Migration[5.0]
 def change
   create_table :submissions do |t|
     t.integer  :submission_id
     t.integer  :user_id
     t.text     :pretest_error
     t.datetime :created_at
     t.datetime :updated_at
     t.string   :exercise_name
     t.integer  :course_id
     t.boolean  :processed
     t.boolean  :all_tests_passed
     t.text     :points
     t.datetime :processing_tried_at
     t.datetime :processing_began_at
     t.datetime :processing_completed_at
     t.integer  :times_sent_to_sandbox
     t.datetime :processing_attempts_started_at
     t.text     :params_json
     t.boolean  :requires_review
     t.boolean  :requests_review
     t.boolean  :reviewed
     t.text     :message_for_reviewer
     t.boolean  :newer_submission_reviewed
     t.boolean  :review_dismissed
     t.boolean  :paste_available
     t.text     :message_for_paste
     t.string   :paste_key

     t.timestamps
   end
 end
end