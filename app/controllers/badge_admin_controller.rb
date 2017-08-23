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
  def all_badgecodes; end

  # GET /badge-admin/badgecode/:badgecode_id
  def one_badgecode; end

  # POST /badge-admin/badgedef
  def new_badgedef; end

  # POST /badge-admin/badgecode
  def new_codedef; end

  # PUT /badge-admin/badgedef/:badgedef_id
  def update_badgedef; end

  # PUT /badge-admin/badgecode/:badgecode_id
  def update_badgecode; end

  # DELETE /badge-admin/badgedef/:badgedef_id
  def delete_badgedef; end

  # DELETE /badge-admin/badgecode/:badgecode_id
  def delete_badgecode; end

  private

  def format_badgedef_for_output(badgedef)
    # "map(&:id)"" does the same as "map { |bc| bc.id }", according to rubocop
    code_ids = badgedef.badge_codes.map(&:id)
    {
      'badgedef_id' => badgedef.id,
      'name' => badgedef.name,
      'iconref' => badgedef.iconref,
      'flavor_text' => badgedef.flavor_text,
      'course_id' => badgedef.course_id,
      'active' => badgedef.active?,
      'badge_codes' => code_ids
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
