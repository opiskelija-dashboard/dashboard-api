class PointSerializer < ActiveModel::Serializer
  attributes :point_id, :course_id, :user_id, :submission_id, :exercise_id, :achieved_at
end
