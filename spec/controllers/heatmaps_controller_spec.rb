require 'spec_helper'

describe HeatmapsController do
  context 'when valid jwt token is provided' do
    before do
      valid_jwt_token
      get '/heatmap/courses/900/all'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end

    it 'returns json with "data" as an element' do
      expect(json['data']).not_to be_nil
    end

    it 'returns "data" element correctly' do
      expect(json['data'].first.class).to eq(Array)
    end

    it 'returns a date string and a float as first array elements in "data"' do
      expect(json['data'].first[1].class).to eq(Integer)
      expect(json['data'].first[0].class).to eq(String)
      # String =~ Regexp returns nil if there's no match,
      # index of start of match if there is a match.
      expect(json['data'].first[0] =~ /^\d\d\d\d-\d\d-\d\d/).not_to be_nil
    end
  end

  context 'when invalid JWT token is provided' do
    before do
      invalid_jwt_token
      get '/heatmap/courses/900/all'
    end

    it 'responds with a 401 Unauthorized status' do
      expect(last_response.status).to eq 401
    end
  end
end
