class MasteryPercentage
  include ActiveModel::Serializers::JSON
  
  #URLS - Change these to the correct ones when possible.
  SKILLS_URL = 'http://secure-wave-81252.herokuapp.com/skills'
  
  def set_skills(url)
    skills = []
    
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    
    hash = JSON.parse response.body
    hash.each do |skill|
      skills << Skill.new(skill['label'], skill['user'], skill['average'])
    end
    skills
  end
  
  def skills
    set_skills(SKILLS_URL)
  end
end
