class CumulativePointsController < ApplicationController
  before_action :set_cumulative_point
  skip_before_action :authenticate_request

  def cumulative_point_current
    render json: @cumulative_point
  end

  private

  def set_cumulative_point
    @cumulative_point = CumulativePoint.new
  end
end
