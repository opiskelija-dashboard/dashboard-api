require 'spec_helper'
require 'jwt'

describe LeaderboardsController do
  context 'when valid jwt token is provided' do

    before do
      jwt_secret = Rails.configuration.jwt_secret
      jwt_hash_algo = 'HS256'
      tomorrow = Time.now.to_i + 86400
      # tmcuid=2 is guaranteed to show up when using MockPointsStore
      # tmctok is meaningless here, it's just the hex expansion of pi
      token_body = {"tmcusr" => "username", "tmctok" => "243f6a8885a308d3", "tmcuid" => 2, "tmcadm" => false, "exp" => tomorrow}
      valid_jwt_token = JWT.encode(token_body, jwt_secret, jwt_hash_algo)
      authstring = "Bearer " + valid_jwt_token

      header "Authorization", authstring
      get '/leaderboard/course/900/update'
      header "Authorization", authstring
      get '/leaderboard/course/900/all'
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

  context 'when invalid JWT token is provided' do
    before do
      jwt_secret = Rails.configuration.jwt_secret
      jwt_hash_algo = 'HS256'
      two_minutes_ago = Time.now.to_i - 120

      token_body = {"tmcusr" => "username", "tmctok" => "243f6a8885a308d3", "tmcuid" => 2, "tmcadm" => false, "exp" => two_minutes_ago}
      valid_jwt_token = JWT.encode(token_body, jwt_secret, jwt_hash_algo)
      authstring = "Bearer " + valid_jwt_token

      header "Authorization", authstring
      get '/leaderboard/course/900/update'
    end

    it 'responds with a 401 Unauthorized status' do
      expect(last_response.status).to eq 401
    end

  end


end
