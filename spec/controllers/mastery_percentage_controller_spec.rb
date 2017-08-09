require "spec_helper"
require 'jwt'

describe MasteryPercentagesController do
  context 'when correct authorization credentials are given' do

    before do
      jwt_token

      get '/skill-percentages'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end

   it 'returns skill percentages' do
     expect(json['skill_percentage']).not_to be_nil
   end
  end

end
