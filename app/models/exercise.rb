class Exercise
  def initialize(id, name)
    @id = id
    @name = name
    @available_points = 0
  end

  def name
    @name
  end

  def id
    @id
  end

  def available_points
    @available_points
  end

  def available_points=(ap)
    available_points = ap
  end
end