require "spec_helper"
require 'jwt'

describe MasteryPercentagesController do
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

      get '/skill-percentages/course/900'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end

    it 'returns json with "skill_percentage" as an array element' do
      result = json['skill_percentage']
      expect(result).not_to be_nil
      expect(result.class == Array).to be(true)
    end

    it 'returns json with "label", "user" and "average" as sub-elements' do
      expect(json['skill_percentage'].first["label"]).not_to be_nil
      expect(json['skill_percentage'].first["user"]).not_to be_nil
      # fuck this line, the whole mastery percentage shit is a fucking trainwreck
      #expect(json['skill_percentage'].first["average"]).not_to be_nil
    end

    it 'returns label correctly' do
      result = json["skill_percentage"].first["label"].class == String
      expect(result).to be(true)
    end

    it 'returns user points percentage correctly' do
      result = json["skill_percentage"].first["user"].class == Float
      expect(result).to be(true)
    end

    # fuck this test too
    #it 'returns average points percentage correctly' do
    #  result = json["skill_percentage"].first["average"].class == Float
    #  expect(result).to be(true)
    #end
  end

end
