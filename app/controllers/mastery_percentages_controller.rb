class MasteryPercentagesController < ApplicationController
  before_action :mastery_percentage
  
  skip_before_action :authenticate_request
  
  
  def skill_percentage_current
    render json: @mastery_percentage
  end
  
  private
  
  def mastery_percentage
    @mastery_percentage = MasteryPercentage.new
  end
end
