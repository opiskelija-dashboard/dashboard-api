class Point
  def initialize(id, submission_id)
    @id = id
    @submission_id = submission_id
  end

  def getSubmissionId
    @submission_id
  end

  def getId
    @id
  end
end
