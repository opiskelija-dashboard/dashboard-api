class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    token_string = unpack_token_from_header

    return false if token_string == false || token_string.nil?

    token = Token.new_from_jwt_string(token_string)
    if token.valid?
      @token = token
      return true
    else
      if token.errors?
        render json: {
          errors: token.errors
        }, status: 401
      else
        render json:
        {
          errors:
          [{
            title: 'Unknown token error',
            detail: 'The JWT token you gave was invalid, but no more specific error is known.'
          }]
        }, status: 401
      end
      return false
    end
  end

  def unpack_token_from_header
    if request.headers['Authorization'].present?
      header = request.headers['Authorization']
      regex = /^Bearer (.*)/
      encoded_token_string = header[regex, 1]

      if encoded_token_string.nil?
        render json:
        {
          errors:
          [{
            title: 'No JWT token in header',
            detail: "The server's string processing facilities failed to see
                    a token (prefixed by 'Bearer ') in the Authorization header."
          }]
        }, status: 401
        return false
      end
      encoded_token_string

    else
      render json:
      {
        errors:
        [{
          title: "Missing 'Authorization' header",
          detail: 'This resource requires a valid JSON Web Token signed by this server.'
        }]
      }, status: 401
      false
    end
  end
end
