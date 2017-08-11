require 'spec_helper'
require 'jwt'

describe LeaderboardsController do
  context 'when correct authorization credentials are given' do

    before do
      jwt_token

      get '/leaderboard/course/214/update'
      get '/leaderboard/course/214/all'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end

    it 'returns json with "data" as an element' do
      expect(json["data"]).not_to be_nil
    end

    it 'returns user_id correctly' do
      result = json["data"].first["user_id"].class == Fixnum
      expect(result).to be(true)
    end

    it 'returns points correctly' do
      result = json["data"].first["points"].class == Fixnum
      expect(result).to be(true)
    end
  end
end
