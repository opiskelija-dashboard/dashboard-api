class MockBadges 
  
  def self.save(something)
    #nothing here
  end
  
  def self.update(something)
    #nothing here either
  end
  
  def self.all
    return @badges
  end
  
  @badges = [
  { "name" => "test2",
  "criteria" => 
  %q(
    found = false
    all_points.each do |raw_point|
      found = true if (raw_point["awarded_point"]["user_id"] == user_id[0]);
    end
    found
    )
  }]

end