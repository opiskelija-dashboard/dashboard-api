class BadgeAdminController < ApplicationController
  before_action :require_adminicity

  # GET /badge-admin/badgedef/all
  def all_badgedefs
  end

  # GET /badge-admin/badgedef/:badgedef_id
  def one_badgedef
  end

  # GET /badge-admin/badgecode/all
  def all_badgecodes
  end

  # GET /badge-admin/badgecode/:badgecode_id
  def one_badgecode
  end

  # POST /badge-admin/badgedef
  def new_badgedef
  end

  # POST /badge-admin/badgecode
  def new_codedef
  end

  # PUT /badge-admin/badgedef/:badgedef_id
  def update_badgedef
  end

  # PUT /badge-admin/badgecode/:badgecode_id
  def update_badgecode
  end

  # DELETE /badge-admin/badgedef/:badgedef_id
  def delete_badgedef
  end

  # DELETE /badge-admin/badgecode/:badgecode_id
  def delete_badgecode
  end


  private

  def require_adminicity
    return true if @token.admin?
    # else:
    render json: {
      'errors' => [
        {
          'title' => 'Not an admin',
          'detail' => 'Your token needs to have the \'tmcadm\' bit set before you can access this end point.'
        }
      ]
    }
    false
  end

end
