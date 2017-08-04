class MasteryPercentage
  include ActiveModel::Serializers::JSON
  
  #URLS - Change these to the correct ones when possible.
  SKILLS_URL = 'http://secure-wave-81252.herokuapp.com/skills'
  EXERCISES_URL = 'http://secure-wave-81252.herokuapp.com/exercises'
  INCLUDABLES_URL = 'http://secure-wave-81252.herokuapp.com/skills-raw'
  CURRENT_USER_POINTS_URL = 'http://secure-wave-81252.herokuapp.com/points'
  USER_POINTS_URL = 'http://secure-wave-81252.herokuapp.com/all_points'
  
  def make_http_request_hash(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    
    JSON.parse response.body
  end
  
  def set_skills(url)    
    skills = []
    hash = make_http_request_hash(url)
    
    hash.each do |skill|
      skills << Skill.new(skill['label'], skill['user'], skill['average'])
    end
    skills
  end
  
  # Returns a hash of all exercises: key = id, value = available points.
  def set_all_exercises(url)
    exercises = {}
    hash = make_http_request_hash(url)

    hash.each do |exercise|
      exercises[exercise['id']] = exercise['available_points']
    end
    exercises
  end
  
  # Returns a hash of exercises that correspond certain labels: key = label, value = array of exercises.
  def set_includable_exercises(url)
    includables = {}
    hash = make_http_request_hash(url)
    
    hash.each do |includable|
      includables[includable['label']] = includable['exercises']
    end
    includables
  end
  
  # Intersects all exercises (ids) and those that correspond certain labels to a hash.
  def intersect_ids
    includables = set_includable_exercises(INCLUDABLES_URL)
    all_exercises = set_all_exercises(EXERCISES_URL)
    
    intersect_ids = {}
    includables.each do |label, array|
      ids = includables[label].map {|inc| inc["id"]}
      intersect_ids[label] = all_exercises.keys & ids
    end
    intersect_ids
  end
  
  # Returns a hash of available points corresponding certain labels.
  def match_labels_and_available_points
    all_exercises = set_all_exercises(EXERCISES_URL)
    intersect = intersect_ids
    
    available_points = {}
    intersect.each do |label, array|
      
      array.each do |id|
        
        if available_points[label] == nil
          available_points[label] = all_exercises[id]
        else
          available_points[label] = available_points[label] + all_exercises[id]
        end
      end
      available_points[label].flatten.uniq
      
    end
    
    available_points
  end
  
  def user_skills
    user_skill_points = {}
    match_labels_and_available_points.each do | label, array |
      user_skill_points[label] = (array.map {|point| point["id"]}.uniq) & (CumulativePoint.new.user_points[0].map {|point| point.id}.uniq)
    end
    user_skill_points
  end
  
  def user_skill_percentage
    hash = {}
    user_skill_points = user_skills
    match_hash = match_labels_and_available_points
    user_skill_points.each do | label, array |
      hash[label] = array.count / match_hash[label].count.to_f
    end
  end
  
  #def all_skills
  #  skill_points = {}
  #  match_labels_and_available_points.each do | label, array |
    #    skill_points[label] = array & (@awarded_points.map {|point| point.id}.uniq)
    
    #  end
    #  skill_points
    #end
    
    def skills
      set_skills(SKILLS_URL)
    end
  end