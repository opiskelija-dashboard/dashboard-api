require 'spec_helper'

describe SkillMasteriesController do
  context "when visiting current user's skill mastery with a valid jwt token" do
    before do
      valid_jwt_token
      get '/skill-mastery/course/900/whereis/current'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end
  end

  context 'when visiting all skill mastery with a valid jwt token' do
    before do
      valid_jwt_token
      get '/skill-mastery/course/900/all'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end
  end

  context 'when visiting combined skill mastery with a valid jwt token' do
    before do
      valid_jwt_token
      get '/skill-mastery/course/900/combined'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end

    it 'returns json with "data" as an array element' do
      result = json['data']
      expect(result).not_to be_nil
      expect(result.class == Array)
    end

    it 'returns json with "label", "user" and "all" as sub-elements' do
      expect(json['data'].first['label']).not_to be_nil
      expect(json['data'].first['user']).not_to be_nil
      expect(json['data'].first['all']).not_to be_nil
    end

    it 'returns statement labels correctly' do
      result = json['data'].first['label'].class == String
      expect(result)
    end

    it "returns current user's skill mastery correctly" do
      result = json['data'].first['user'].class == Float
      expect(result)
    end

    it 'returns all skill mastery correctly' do
      result = json['data'].first['all'].class == Float
      expect(result)
    end
  end

  context 'when invalid JWT token is provided' do
    before do
      invalid_jwt_token
      get '/skill-mastery/course/900/combined'
    end

    it 'responds with a 401 Unauthorized status' do
      expect(last_response.status).to eq 401
    end
  end
end
