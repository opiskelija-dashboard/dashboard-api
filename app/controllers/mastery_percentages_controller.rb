class MasteryPercentagesController < ApplicationController
  skip_before_action :authenticate_request

  def skill_percentage_current
    @mastery_percentage = MasteryPercentage.new
    render json: @mastery_percentage
  end
end
