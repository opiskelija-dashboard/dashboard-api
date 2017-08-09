require "spec_helper"
require 'jwt'

describe CumulativePointsController do
  context 'when correct authorization credentials are given' do

    before do
      jwt_token

      get '/cumulative-points'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end

    it 'returns days, points and average' do
      expect(json["days"]).not_to be_nil
      expect(json["points"]).not_to be_nil
      expect(json["average"]).not_to be_nil
    end
  end
end
