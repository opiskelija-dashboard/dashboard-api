class CumulativePointsController < ApplicationController
  def cumulative_point_current
    @cumulative_point = CumulativePoint.new(@token)
    render json: @cumulative_point
  end
end
