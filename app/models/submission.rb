class Submission
  def initialize(id, created_at)
    @id = id
    @created_at = created_at
  end

  def getCreatedAt
    @created_at
  end

  def getId
    @id
  end
end
