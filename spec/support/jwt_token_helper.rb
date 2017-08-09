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