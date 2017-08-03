class MasteryPercentagesController < ApplicationController
  before_action :set_mastery_percentage

  def skill_percentage_current
    render json: @mastery_percentage
  end

  private

  def set_mastery_percentage
    @mastery_percentage = MasteryPercentage.new
  end
end
