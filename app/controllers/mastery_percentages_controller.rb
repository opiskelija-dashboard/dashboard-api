class MasteryPercentagesController < ApplicationController
  def skill_percentage_current
    @mastery_percentage = MasteryPercentage.new(@token)
    render json: @mastery_percentage
  end
end
