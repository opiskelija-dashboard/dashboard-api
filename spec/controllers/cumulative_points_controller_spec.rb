require 'spec_helper'
require 'jwt'

describe CumulativePointsController do
  context 'when valid jwt token is given are given' do

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
      puts last_response.inspect
      expect(last_response.status).to eq 200
    end

    it 'returns json with "data" as the top element and "user" and "average" as sub-elements' do
      puts json.inspect
      expect(json["data"]).not_to be_nil
      expect(json["data"]["user"]).not_to be_nil
      expect(json["data"]["average"]).not_to be_nil
    end

    it 'returns user-specific data' do
      expect(json["data"]["user"].class == Array).to be(true)
    end

    it 'returns averages' do
      expect(json["data"]["average"].class == Hash).to be(true)
    end

  end
end
