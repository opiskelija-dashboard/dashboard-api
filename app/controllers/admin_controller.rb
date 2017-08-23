class AdminController < ApplicationController

  # GET /is-admin
  # We need a server-side facility to check whether a JWT token has the tmcadm
  # field set true or not because, while the JWT token can be read on the
  # client side (it's not encrypted, just Base64-encoded), it can't be
  # verified, because the client doesn't know the server's secret key.
  # This facility here is just one layer of defense, and provided as a
  # convenience: it is hoped that the client will check here before showing
  # the user any administrative pages or controls. Even if this doesn't happen,
  # no administrative actions will be carried out (the tmcadm field will still
  # be false), but the end-user might be frustrated because controls that
  # were shown were not to be used and using them caused either nothing to
  # happen or errors to appear.
  def is_admin
    admin_bit = @token.admin?
    render json: { 'admin' => admin_bit }, status: 200 #OK
  end

end
