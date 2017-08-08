class CumulativePointsController < ApplicationController
  skip_before_action :authenticate_request

  def cumulative_point_current
    @cumulative_point = CumulativePoint.new
    render json: @cumulative_point
  end
end
