require 'spec_helper'

describe MasteryPercentagesController do
  context 'when valid jwt token is provided' do
    before do
      valid_jwt_token

      get '/skill-percentages/course/900'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end

    it 'returns json with "skill_percentage" as an array element' do
      result = json['skill_percentage']
      expect(result).not_to be_nil
      expect(result.class == Array)
    end

    it 'returns json with "label", "user" and "average" as sub-elements' do
      expect(json['skill_percentage'].first['label']).not_to be_nil
      expect(json['skill_percentage'].first['user']).not_to be_nil
    end

    it 'returns label correctly' do
      result = json['skill_percentage'].first['label'].class == String
      expect(result)
    end

    it 'returns user points percentage correctly' do
      result = json['skill_percentage'].first['user'].class == Float
      expect(result)
    end

    context 'when invalid JWT token is provided' do
      before do
        invalid_jwt_token
        get '/skill-percentages/course/900'
      end

      it 'responds with a 401 Unauthorized status' do
        expect(last_response.status).to eq 401
      end
    end
  end
end
