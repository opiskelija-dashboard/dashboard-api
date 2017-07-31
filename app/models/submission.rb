class Submission < ApplicationRecord
  validates :submission_id, uniqueness: true
  has_many :points, dependent: :destroy

  def set_arrays
    
  end

  # Array of all the days including the ones with no submissions.
 # def days
 # end

  # Array of points achieved corresponding the days of the same index.
 # def points
 # end
end
