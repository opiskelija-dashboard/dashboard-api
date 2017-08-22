class BadgeAdminController < ApplicationController
  before_action :require_adminicity

  # GET /badge-admin/badgedef/all
  def get_all_badgedefs
  end

  # GET /badge-admin/badgedef/:badgedef_id
  def get_badgedef
  end

  # GET /badge-admin/badgecode/all
  def get_all_badgecodes
  end

  # GET /badge-admin/badgecode/:badgecode_id
  def get_badgecode
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
    unless @token.admin?
      render json: {
        "errors": [
          {
            "title" => "Not an admin",
            "detail" => "Your token needs to have the 'tmcadm' bit set before you can access this end point."
          }
        ]
      }
      return false
    end
  end

end
