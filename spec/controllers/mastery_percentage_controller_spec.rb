require "spec_helper"
require 'jwt'

describe MasteryPercentageController do
  context 'when correct authorization credentials are given' do

    before do
      jwt_secret = Rails.configuration.jwt_secret

      token_payload = {
      "tmcusr" => "user",
      "tmctok" => "token",
      "exp" => (Time.now + 86400).to_i
      }

      JWT_HASH_ALGO = 'HS256'
      token = JWT.encode(token_payload, jwt_secret, JWT_HASH_ALGO)
      header "Authorization", "Bearer #{token}"

      get '/skill-percentages'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end

   it 'returns days, points and average' do
     
   end
  end

end
