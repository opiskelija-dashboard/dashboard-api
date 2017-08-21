require 'spec_helper'
require 'jwt'

describe CumulativePointsController do
  context 'when valid jwt token is provided' do

    before do
      jwt_secret = Rails.configuration.jwt_secret
      jwt_hash_algo = 'HS256'
      tomorrow = Time.now.to_i + 86400
      # tmcuid=2 is guaranteed to show up when using MockPointsStore
      # tmctok is meaningless here, it's just the hex expansion of pi
      token_body = {"tmcusr" => "username", "tmctok" => "243f6a8885a308d3", "tmcuid" => 2, "exp" => tomorrow}
      valid_jwt_token = JWT.encode(token_body, jwt_secret, jwt_hash_algo)
      authstring = "Bearer " + valid_jwt_token

      header "Authorization", authstring
      get '/cumulative-points/course/900'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end

    it 'returns json with "data" as the top element and "day", "point" and "average" as sub-elements' do
      expect(json["data"]).not_to be_nil
      expect(json["data"][0]["date"]).not_to be_nil
      expect(json["data"][0]["users_points"]).not_to be_nil
      expect(json["data"][0]["everyones_average"]).not_to be_nil
    end

    it 'returns user-specific data' do
      expect(json["data"].class == Array).to be(true)
      # We know there is at least one point with UID=2, hence there must be
      # at least one point in here.
      expect(json["data"].count > 0).to be(true)
    end

    it 'returns day in form of Y-M-D dates' do
      # String =~ Regexp returns nil if there's no match,
      # index of start of match if there is a match.
      expect(json["data"][0]["date"] =~ /^\d\d\d\d-\d\d-\d\d/).not_to be_nil
    end

  end

  context 'when invalid JWT token is provided' do
    before do
      jwt_secret = Rails.configuration.jwt_secret
      jwt_hash_algo = 'HS256'
      two_minutes_ago = Time.now.to_i - 120

      token_body = {"tmcusr" => "username", "tmctok" => "243f6a8885a308d3", "tmcuid" => 2, "exp" => two_minutes_ago}
      valid_jwt_token = JWT.encode(token_body, jwt_secret, jwt_hash_algo)
      authstring = "Bearer " + valid_jwt_token

      header "Authorization", authstring
      get '/cumulative-points/course/900'
    end

    it 'responds with a 401 Unauthorized status' do
      expect(last_response.status).to eq 401
    end

  end

end
