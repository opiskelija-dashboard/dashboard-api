# A helper to give fake valid/invalid jwt token to spec files.
# Included in the spec_helper.rb - which is needed for our helper module to work.
# Use this module with simply calling 'valid/invalid_jwt_token' in a spec file.

require 'jwt'

module JwtTokenHelper
  def valid_jwt_token
    jwt_token(Time.now.to_i + 86400)
  end

  def invalid_jwt_token
    jwt_token(Time.now.to_i - 120)
  end

  private

  def jwt_token(expiration_date)
    jwt_secret = Rails.configuration.jwt_secret
    jwt_hash_algo = 'HS256'
    two_minutes_ago = expiration_date

    token_body = {'tmcusr' => 'username', 'tmctok' => '243f6a8885a308d3', 
                  'tmcuid' => 2, 'exp' => two_minutes_ago}

    token = JWT.encode(token_body, jwt_secret, jwt_hash_algo)
    
    header "Authorization", "Bearer #{token}"
  end
end