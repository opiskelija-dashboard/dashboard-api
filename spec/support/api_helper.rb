# A helper to include Rack methods in our API controller tests.

module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end
end
