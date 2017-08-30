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
    fake_course = 900
    MockPointsStore.force_update_course_points(fake_course)
    course_points = MockPointsStore.course_points(fake_course)
    # TODO fetch/calculate exerices, isolate user_points from course_points
    bin_ding = bc.appropriate_binding(fake_user, course_points, user_points, exercises)
    bugs = false
    error_objects = []
    begin
      code = bc.code
      name = bc.name
      # Second parameter becomes the "filename" in any error reports.
      bin_ding.eval(code, name)
    rescue ScriptError => e
      bugs = true
      error_objects.push(exception_to_error_object(e))
    rescue StandardError => e
      bugs = true
      error_objects.push(exception_to_error_object(e))
    end
    { :bugs => bugs, :errors => error_objects }
  end

  # On the 'points' parameter: this can either be course points or all
  # points. It is assumed that this subroutine will be called in a context
  # that assures that only course-specific badgedefs will be matched with
  # course-specific data; and likewise with s/course-specific/global/.
  def self.evaluate_badgedef(badgedef, user_id, course_points, user_points, exercises)
    badge_codes = badgedef.badge_codes
    eval_results = {}
    ok = {}
    errors = []

    badge_codes.each do |bc|
      foo = evaluate_badge_code(bc, user_id, course_points, user_points, exercises)
      ok[bc.id] = foo[:ok]
      eval_results[bc.id] = foo[:val]
      foo[:errors].each { |e|
        e[:bcid] = bc.id;
        e[:bdid] = badgedef.id;
        errors.push(e)
      }
    end

    all_ok = true
    # Simulate ok.first AND ok.second AND ... AND ok.last
    ok.each_value { |v| all_ok = false if !v }

    give_badge = true
    eval_results.each_value { |v| give_badge = false if !v }

    ret = { give_badge: give_badge, ok: all_ok, errors: errors }
    Rails.logger.debug("BDef #{badgedef.id}: #{ret.inspect}")
    ret
  end

  # Grabs the appropriate binding for the BadgeCode and evaluates it,
  # catching any Script- or StandardErrors the code throws. Returns a
  # hash like this:
  # { :ok => t/f, :val => eval result, :errors => [any that were found] }
  def self.evaluate_badge_code(bc, user_id, course_points, user_points, exercises)
    # Rails.logger.debug("Evaluating BadgeCode #{bc.id}")
    bin_ding = bc.appropriate_binding(user_id, course_points, user_points, exercises)
    error_objects = []
    ok = true
    begin
      code = bc.code
      name = bc.name
      evalval = bin_ding.eval(code, name)
    rescue ScriptError => e
      error_objects.push(exception_to_error_object(e))
      ok = false
    rescue StandardError => e
      error_objects.push(exception_to_error_object(e))
      ok = false
    end
    ret = { ok: ok, val: evalval, errors: error_objects }
    Rails.logger.debug("BCode #{bc.id}: #{ret.inspect}")
    ret
  end

  private

  def self.exception_to_error_object(e)
    # Exception#inspect = class name and message.
    { title: 'Code error', detail: "#{e.inspect}" }
  end

end
