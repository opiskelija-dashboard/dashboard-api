require 'spec_helper'

# With CoursePointsController we can specifically test our (Mock)?PointStores
describe CoursePointsController do
  context 'when valid JWT token is provided' do
    before do
      valid_jwt_token
      get '/course-points/900/update'
    end

    it 'responds with a 200 status' do
      expect(last_response.status).to eq 200
    end
  end

  context 'when invalid JWT token is provided' do
    before do
      invalid_jwt_token
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
