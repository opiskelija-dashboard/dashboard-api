require 'spec_helper'

describe CumulativePointsController do
  context 'when valid jwt token is provided' do
    before do
      valid_jwt_token
      get '/cumulative-points/course/900'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end

    it 'returns json with "data" as the top element' do
      expect(json['data']).not_to be_nil
    end

    it 'returns "date", "user_points" and "average" as sub-elements' do
      expect(json['data'][0]['date']).not_to be_nil
      expect(json['data'][0]['users_points']).not_to be_nil
      expect(json['data'][0]['everyones_average']).not_to be_nil
    end

    it 'returns user-specific data' do
      expect(json['data'].class).to eq(Array)
      # We know there is at least one point with UID=2, hence there must be
      # at least one point in here.
      expect(!json['data'].empty?)
    end

    it 'returns day in form of Y-M-D dates' do
      # String =~ Regexp returns nil if there's no match,
      # index of start of match if there is a match.
      result = json['data'][0]['date'] =~ /^\d\d\d\d-\d\d-\d\d/
      expect(result).not_to be_nil
    end
  end

  context 'when invalid JWT token is provided' do
    before do
      invalid_jwt_token
      get '/cumulative-points/course/900'
    end

    it 'responds with a 401 Unauthorized status' do
      expect(last_response.status).to eq 401
    end
  end
end
