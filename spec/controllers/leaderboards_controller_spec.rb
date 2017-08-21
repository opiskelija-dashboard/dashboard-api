require 'spec_helper'

describe LeaderboardsController do
  context 'when valid jwt token is provided' do
    before do
      valid_jwt_token
      get '/leaderboard/course/900/all'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end

    it 'returns json with "data" as an element' do
      expect(json['data']).not_to be_nil
    end

    it 'returns user_id correctly' do
      result = json['data'].first['user_id'].class == Integer
      expect(result)
    end

    it 'returns points correctly' do
      result = json['data'].first['points'].class == Integer
      expect(result)
    end
  end

  context 'when invalid JWT token is provided' do
    before do
      invalid_jwt_token
      get '/leaderboard/course/900/update'
    end

    it 'responds with a 401 Unauthorized status' do
      expect(last_response.status).to eq 401
    end
  end
end
