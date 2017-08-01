class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    token_payload = decode_token_from_header

    if token_payload
      # because the token was signed by us, we can trust it
      @token = token_payload
      return true
    else
      render json: { "errors" => # json:api format
          [{
            "title" => "No Auth Token",
            "detail" => "Either: a JWT token was not included in the Authorization HTTP header; the header was malformed; or the token is invalid or corrupt.",
          }]
        },
        status: 401
    end

  end

  def decode_token_from_header
    if request.headers['Authorization'].present?
      header = request.headers['Authorization']
      regex = /^Bearer (.*)/
      encoded_token_string = header[regex, 1]
      
      if (encoded_token_string.nil?)
        return nil
      end

      # in proper use we'd fetch the secret from a conf file or
      # environment variable instead of hardcoding it into the program
      secret = 'secret'

      decoded_token = JWT.decode(encoded_token_string, secret, true, {:algorithm => 'HS256'})
      # the format:
      # [{"tmcusr"=>  "username", "tmctok"=>"ABCD", "exp"=>1500000000}, {"typ"=>"JWT", "alg"=>"HS256"}]
      #Rails.logger.debug(decoded_token.inspect)

      token_payload = decoded_token[0]
      return token_payload
    end
    rescue JWT::VerificationError
      
      render json: { "errors" => # json:api format
          [{
            "title" => "Invalid Auth Token",
            "detail" => "Either: a JWT token was not included in the Authorization HTTP header; the header was malformed; or the token is invalid or corrupt.",
          }]
        },
        status: 401
  end

end
