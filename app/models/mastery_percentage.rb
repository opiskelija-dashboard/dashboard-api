class MasteryPercentage
  include ActiveModel::Serializers::JSON

  #URLS - Change these to the correct ones when possible.
  SKILLS_ENDPOINT = '/courses/:course_id/users/:user_id/skills'
  EXERCISES_ENDPOINT = '/courses/:course_id/exercises'
  LABELED_EXERCISES_ENDPOINT = '/courses/:course_id/skills-raw'

  # set this from config/application.rb
  API_BASE_ADDRESS = 'http://secure-wave-81252.herokuapp.com/api/v8'

  def initialize(token)
    @token = token
  end

  # Returns a hash of all exercises: key = id, value = available points.
  def get_all_exercises(endpoint)
    exercises = {}

    # without the API_BASE_ADDRESS this will use Rails.configuration.tmc_api_base_address,
    # like everything should
    response = HttpHelpers.tmc_api_get(endpoint, @token.tmc_token, API_BASE_ADDRESS)

    if response[:success]
      response[:body].each do |e|
        exercises[e['id']] = e['available_points']
      end
      exercises
    end
  end

  # Returns a hash of exercises by certain labels: key = label, value = array of exercises.
  def get_exercises_by_labels(endpoint)
    exercises = {}

    # without the API_BASE_ADDRESS this will use Rails.configuration.tmc_api_base_address,
    # like everything should
    response = HttpHelpers.tmc_api_get(endpoint, @token.tmc_token, API_BASE_ADDRESS)

    if response[:success]
      response[:body].each do |e|
        exercises[e['label']] = e['exercises']
      end
      exercises
    end
  end

  # Intersects all exercises (ids) with some that correspond labels, to a hash.
  def intersect_exercise_ids
    all = get_all_exercises(EXERCISES_ENDPOINT)

    intersect_ids = {}
    get_exercises_by_labels(LABELED_EXERCISES_ENDPOINT).each do |label, exercise|
      ids = exercise.map {|e| e["id"]}
      intersect_ids[label] = all.keys & ids
    end
    intersect_ids
  end

  # Returns a hash of available points corresponding labels.
  def match_labels_with_available_points
    all_exercises = get_all_exercises(EXERCISES_ENDPOINT)
    intersect_ids = intersect_exercise_ids

    available_points = {}
    intersect_ids.each do |label, ids|
      ids.each do |id|
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

  # Returns a hash of labels as keys and corresponding current user's points as values.
  def user_skills
    user_skill_points = {}
    match_labels_with_available_points.each do | label, points |
      user_skill_points[label] = (points.map {|point| point["id"]} & CumulativePoint.new(@token).user_points[0].map {|point| point.id})
    end
    user_skill_points
  end

  # Returns a hash of labels as keys and corresponding number of awarded points as value.
  def all_skills
    skill_points = {}
    cp = CumulativePoint.new(@token).all_points[0].map {|point| point.id}
    match_labels_with_available_points.each do | label, points |
      hash = {}

      point_ids = points.map {|point| point["id"]} # ids
      point_ids.each do |id|
        hash[id] = cp.count(id)
      end
      skill_points[label] = hash.values.inject(0){ |sum,x| sum + x }
    end
    skill_points
  end

  # Returns a hash of labels as keys and corresponding skill ratio as value.
  def user_skill_ratio
    skill_ratio = {}
    user_skills.each do | label, points |
      skill_ratio[label] = points.count / match_labels_with_available_points[label].count.to_f
    end
    skill_ratio
  end

  # Returns a hash of labels as keys and corresponding average number of points as value.
  def label_average
    average = {}
    all_skills.each do | label, number_of_points |
      average[label] = number_of_points.to_f / CumulativePoint.new(@token).all_points[1].count / match_labels_with_available_points[label].count
    end
    average
  end

  # Returns array including: labels and corresponding final percentages (current user and all users).
  def skill_percentage
    avg = label_average
    labels = avg.keys
    all = avg.values
    current_user = user_skill_ratio.values

    percentages = []
    i = 0
    begin
      partial = {}
      partial["label"] = labels[i]
      partial["user"] = (current_user[i]*100).round(1)
      partial["average"] = (all[i]*100).round(1)
      percentages << partial
      i = i + 1
    end until i == labels.count
    percentages
  end

  # Returns hardcoded skill percentages (for now from mock-API).
  def skills(endpoint)
    skills_array = []

    # without the API_BASE_ADDRESS this will use Rails.configuration.tmc_api_base_address,
    # like everything should
    response = HttpHelpers.tmc_api_get(endpoint, @token.tmc_token, API_BASE_ADDRESS)

    if response[:success]
      response[:body].each do |skill|
        skills_array << Skill.new(skill['label'], skill['user'], skill['average'])
      end
      skills_array
    end
  end

  # NOTE! When there is a useful TMC server end point for ready skill procentages:
  # replace the SKILLS_ENDPOINT below and in the beginning of the file with corresponding correct API address path.
  #def skill_percentages
  #  skills(SKILLS_ENDPOINT)
  #end
end
