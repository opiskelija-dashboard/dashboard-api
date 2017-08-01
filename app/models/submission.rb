class Submission < ApplicationRecord
  validates :submission_id, uniqueness: true
  has_many :points, dependent: :destroy

  # Array of all the days including the ones with no submissions.
  def set_array
    array = []
    Point.all.each do |p|
      array << p.submission.created_at.to_date
    end

    array = array.sort
    h = {}

    dateNow = array.first

    begin
      h["#{dateNow}"] = 0
      dateNow += 1
    end until dateNow > array.last

    i = 0

    begin
      h["#{array[i]}"] = h["#{array[i]}"] + 1
      i += 1
    end until i == array.count
    
    h
  end

  def days
    set_array.keys
  end

  # Array of points achieved corresponding the days of the same index.
  def points
    h = set_array
    j = 1
    a = Array.new(h.length)
    a[0] = h.values[0]

    begin
      a[j] = a[j - 1] + h.values[j]
      j += 1
    end until j == h.length

    a
  end
end
