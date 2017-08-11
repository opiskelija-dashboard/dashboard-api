require 'spec_helper'
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

    it 'returns json with "days", "points" and "average" as elements' do
      expect(json["days"]).not_to be_nil
      expect(json["points"]).not_to be_nil
      expect(json["average"]).not_to be_nil
    end

    it 'returns days correctly' do
      result = json["days"].first.class == String
      expect(result).to be(true)
    end

    it 'returns points correctly' do
      result = json["points"].first.class == Fixnum
      expect(result).to be(true)
    end

    it 'returns average correctly' do
      result = json["average"].class == Float
      expect(result).to be(true)
    end
  end
end
