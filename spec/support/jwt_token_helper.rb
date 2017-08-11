# A helper to give "correct" jwt token to spec files.
# Included in the spec_helper.rb - this is needed for our helper module to work.
# Use this module with simply calling 'jwt_token' in a spec file.

require 'jwt'

module JwtTokenHelper 
  def jwt_token
    token_payload = {
    "tmcusr" => "user",
    "tmctok" => "token",
    "exp" => (Time.now + 86400).to_i
    }
    token = JWT.encode(token_payload, Rails.configuration.jwt_secret, 'HS256')
    header "Authorization", "Bearer #{token}"
  end
end 