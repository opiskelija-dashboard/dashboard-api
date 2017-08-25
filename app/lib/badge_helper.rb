class BadgeHelper

  # This will take a BadgeCode object, give it some fake but plausible
  # data, get a binding with its #appropriate_binding method,  run the
  # BadgeCode's code in the context of that binding, and check for any
  # (Syntax|Name|LocalJump)Errors. Returns a hash of a thuswise format:
  # { :bugs => true/false, :errors => [ array of Error objects ] }
  # where :errors are any that were caught, & :bugs is true if :errors
  # isn't empty, otherwise the BadgeCode is declared to be "bug-free".
  def self.test_for_errors(bc)
    fake_user = 2
    [899, 900, 901].each do |course_id|
      MockPointsStore.force_update_course_points(course_id)
    end
    all_points = MockPointsStore.all_fake_points
    course_points = MockPointsStore.course_points(900)
    bin_ding = bc.appropriate_binding(fake_user, course_points, all_points)
    bugs = false
    error_objects = []
    begin
      code = bc.code
      name = bc.name
      # Second parameter becomes the "filename" in any error reports.
      bin_ding.eval(code, name)
    rescue ScriptError => e
      bugs = true
      error_objects.push(e_obj)
    rescue StandardError => e
      bugs = true
      error_objects.push(exception_to_error_object(e))
    end
    { :bugs => bugs, :errors => error_objects }
  end

  private

  def self.exception_to_error_object(e)
    # Exception#inspect = class name and message,
    # Exception#backtrace = array of strings, we'll take the first one.
    { title: 'Code error', detail: "#{e.inspect}\n#{e.backtrace[0]}" }
  end

end