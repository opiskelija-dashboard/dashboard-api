class SessionsController < ApplicationController

  def show
    render json: session.to_json
  end

  def set_tmc_access_token
    session[:tmc_access_token] = params[:tmc_access_token]
  end

end
