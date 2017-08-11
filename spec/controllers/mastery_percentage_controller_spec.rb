require "spec_helper"
require 'jwt'

describe MasteryPercentagesController do
  context 'when correct authorization credentials are given' do

    before do
      jwt_token

      get '/skill-percentages'
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
      expect(json['skill_percentage'].first["average"]).not_to be_nil
    end

    it 'returns label correctly' do
      result = json["skill_percentage"].first["label"].class == String
      expect(result).to be(true)
    end

    it 'returns user points percentage correctly' do
      result = json["skill_percentage"].first["user"].class == Float
      expect(result).to be(true)
    end

    it 'returns average points percentage correctly' do
      result = json["skill_percentage"].first["average"].class == Float
      expect(result).to be(true)
    end
  end

end
