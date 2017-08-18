require 'spec_helper'
require 'jwt'

# With CoursePointsController we can specifically test our (Mock)?PointStores
describe CoursePointsController do

  context 'when valid JWT token is provided' do
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
      get '/course-points/900/update'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end

  end

  context 'when invalid JWT token is provided' do
    before do
      jwt_secret = Rails.configuration.jwt_secret
      jwt_hash_algo = 'HS256'
      two_minutes_ago = Time.now.to_i - 120

      # tmcuid=2 is guaranteed to show up when using MockPointsStore
      # tmctok is meaningless here, it's just the hex expansion of pi
      token_body = {"tmcusr" => "username", "tmctok" => "243f6a8885a308d3", "tmcuid" => 2, "tmcadm" => false, "exp" => two_minutes_ago}
      valid_jwt_token = JWT.encode(token_body, jwt_secret, jwt_hash_algo)
      authstring = "Bearer " + valid_jwt_token

      header "Authorization", authstring
      get '/course-points/900/update'
    end

    it 'responds with a 401 Unauthorized status' do
      expect(last_response.status).to eq 401
    end
  end

  context 'when no JWT token is provided' do
    before do
      get '/course-points/900/update'
    end

    it 'responds with a 401 Unauthorized status' do
      expect(last_response.status).to eq 401
    end
  end

end
