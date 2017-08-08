require 'rails_helper'
require "rack/test"

describe "CumulativePoints" do
  it 'sends a list of points' do
    expect(1)

    #    get '/cumulative-points'
    
    #   json = JSON.parse(response.body)
    
      test for the 200 status-code
      expect(response).to be_success
    
    # check to make sure the right amount of points are returned
    # expect(json['points'].length).to eq(10)
  end
end