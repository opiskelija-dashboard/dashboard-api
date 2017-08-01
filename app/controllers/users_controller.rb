class UsersController < ApplicationController

  # Uncomment this if you want to test the application without auth tokens.
  #skip_before_action :authenticate_request

  def demo
    render json: User.first
  end

end
