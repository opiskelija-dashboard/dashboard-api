class BadgeAdminController < ApplicationController
  before_action :require_adminicity

  # GET /badge-admin/badgedef/all
  def all_badgedefs
    all_badgedefs = BadgeDef.all
    badgelist = all_badgedefs.map { |bd| format_badgedef_for_output(bd) }
    render json: { 'data' => badgelist }, status: 200 # OK
  end

  # GET /badge-admin/badgedef/:badgedef_id
  def one_badgedef
    if BadgeDef.exists?(params['badgedef_id'])
      badgedef = BadgeDef.find(params['badgedef_id'])
      render json: { 'data' => format_badgedef_for_output(badgedef) },
             status: 200 # OK
    else
      render json: { 'data' => [] }, status: 404 # Not Found
    end
  end

  # GET /badge-admin/badgecode/all
  def all_badgecodes
    all_badgecodes = BadgeCode.all
    codelist = all_badgecodes.map { |bc| format_badge_code_for_output(bc) }
    render json: { 'data' => codelist }, status: 200 # OK
  end

  # GET /badge-admin/badgecode/:badgecode_id
  def one_badgecode
    if BadgeCode.exists?(params['badgecode_id'])
      bcode = BadgeCode.find(params['badgecode_id'])
      render json: { 'data' => format_badge_code_for_output(bcode) },
             status: 200 # OK
    else
      render json: { 'data' => [] }, status: 404 # Not Found
    end
  end

  # POST /badge-admin/badgedef
  # Expected POST body: JSON, thusly: {
  #   'name' => ..., 'flavor_text' => optional, 'iconref' => optional,
  #   'course_id' => optional, 'global' => true/false, 'active' => true/false,
  #   'badge_codes' => [ array of badge-code-ids, mandatory]
  # }
  # If 'global' is true, 'course_id' is ignored, but if 'global' is false,
  # 'course_id' is required to be a valid TMC course-id, otherwise problems
  # will occur down the line.
  # Returns the created BadgeDef, including its ID.
  def new_badgedef
    can_continue = check_required_fields(%w[name badge_codes])
    # Rails will die and complain otherwise, since we rendered.
    return false unless can_continue

    # check_badge_codes returns the string 'OK' if all BadgeCode IDs are real.
    unless (fake_codes = check_badge_codes(params['badge_codes'])) == 'OK'
      fake_badge_code_death(fake_codes)
      return false
    end

    badgedef = BadgeDef.new(params_to_badgedef_input)
    link_codes_to_def(badgedef, params['badge_codes'])
    # rubocop:disable Metrics/LineLength
    if badgedef.save
      render json: { 'data' => format_badgedef_for_output(badgedef) }, status: 200 # OK
    else
      render json: { 'errors' => [{ 'title' => 'BadgeDef saving failed', 'description' => 'TODO: fill this in' }] }, status: 500 # Internal Server Error
    end
    # rubocop:enable Metrics/LineLength
    # TODO: logging
  end

  # POST /badge-admin/badgecode
  def new_codedef; end

  # PUT /badge-admin/badgedef/:badgedef_id
  def update_badgedef; end

  # PUT /badge-admin/badgecode/:badgecode_id
  def update_badgecode; end

  # DELETE /badge-admin/badgedef/:badgedef_id
  def delete_badgedef
    bdid = params['badgedef_id']
    if BadgeDef.exists?(bdid)
      if BadgeDef.find(bdid).destroy
        render json: { 'data' => "BadgeDef #{bdid} destroyed" },
               status: 200 # OK
      else
        render json: { 'data' => "BadgeDef #{bdid} not destroyed" },
               status: 500 # Internal Server Error
      end
    else
      render json: { 'data' => "BadgeDef #{bdid} not found" }, status: 404
    end
  end

  # DELETE /badge-admin/badgecode/:badgecode_id
  def delete_badgecode; end

  private

  def link_codes_to_def(badgedef, badge_code_ids)
    # TODO: error checking & returning
    badge_code_ids.each do |bcid|
      bc = BadgeCode.find(bcid)
      already_linked = badgedef.badge_codes.exists?(bcid)
      badgedef.badge_codes << bc unless already_linked
    end
  end

  # Returns true/false: true if we can continue, false if we rendered errors.
  def check_required_fields(fields)
    missing_fields = []
    fields.each do |required_field|
      missing_fields.push(required_field) if
        params[required_field].nil? || params[required_field].empty?
    end
    missing_required_field_death(missing_fields) unless missing_fields.empty?
    missing_fields.empty?
  end

  # When we are given an array of badge codes IDs, we first want to check
  # if all of those IDs refer to existent badge codes. This will either return
  # the string "OK", or an array of badge code IDs that were *not* real.
  def check_badge_codes(badge_code_ids)
    fakes = []
    badge_code_ids.each do |bcid|
      fakes.push(bcid) unless BadgeCode.exists?(bcid)
    end
    return 'OK' if fakes.empty?
    fakes
  end

  # rubocop:disable Metrics/LineLength
  # We don't split error messages over multiple lines.
  # This is to preserve greppability.
  def missing_required_field_death(fieldnames)
    errors = []
    fieldnames.each do |fieldname|
      error = { 'title' => 'Required field missing', 'detail' => "The given parameters were missing the required `#{fieldname}` field." }
      errors.push(error)
    end
    render json: { 'errors' => errors }, status: 400 # Bad Request
  end

  def fake_badge_code_death(fake_codes)
    errors = []
    fake_codes.each do |fake_code|
      error = { 'title' => 'Invalid BadgeCode id',
                'detail' => "The id #{fake_code} does not refer to a BadgeCode record.",
                'invalid_id' => fake_code }
      # We return the naked ID ^^^ so that the client can display errors
      # based on it easily, if necessary.
      errors.push(error)
    end
    render json: { 'errors' => errors }, status: 400 # Bad Request
  end
  # rubocop:enable Metrics/LineLength

  # This assumes you've already checked that all necessary params exist.
  def params_to_badgedef_input
    {
      'name' => params['name'],
      'iconref' => params['iconref'],
      'flavor_text' => params['flavor_text'],
      'global' => params['global'],
      'course_specific' => params['course_specific'] || !params['global'],
      'course_id' => params['course_id'],
      'active' => params['active']
    }
  end

  def format_badgedef_for_output(badgedef)
    # "map(&:id)" does the same as "map { |bc| bc.id }", according to rubocop
    code_ids = badgedef.badge_codes.map(&:id)
    {
      'badgedef_id' => badgedef.id,
      'name' => badgedef.name,
      'iconref' => badgedef.iconref,
      'flavor_text' => badgedef.flavor_text,
      'course_id' => badgedef.course_id,
      'active' => badgedef.active?,
      'global' => badgedef.global?,
      'course_specific' => badgedef.course_specific?,
      'badge_codes' => code_ids
    }
  end

  def format_badge_code_for_output(bcode)
    # BadgeCode records also have a virtual field, `badge_defs`, which
    # is an array of all BadgeDef records that use the current BadgeCode.
    {
      'badgecode_id' => bcode.id,
      'name' => bcode.name,
      'description' => bcode.description,
      'code' => bcode.code,
      'bugs' => bcode.bugs?,
      'course_specific' => bcode.course_points_only?
    }
  end

  def require_adminicity
    return true if @token.admin?
    # else:
    # rubocop:disable Metrics/LineLength
    # Linux-styleguide approach to long lines: in general, no, except with
    # error messages, which should be on one line so they can be grepped.
    render json: {
      'errors' => [
        {
          'title' => 'Not an admin',
          'detail' => "Your token needs to have the 'tmcadm' bit set before you can access this end point."
        }
      ]
    }, status: 401
    # rubocop:enable Metrics/LineLength
    false
  end
end
