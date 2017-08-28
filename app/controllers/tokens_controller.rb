class TokensController < ApplicationController
  skip_before_action :authenticate_request

  def newtoken
    Rails.logger.info('JWT secret: ' + Rails.configuration.jwt_secret)

    tmc_username = params[:tmc_username]
    tmc_access_token = params[:tmc_access_token]

    token = Token.new_from_credentials(tmc_username, tmc_access_token)

    if token.errors?
      render json: { # json:api format
        'errors' => token.errors
      }, status: 401 # Unauthorized
    elsif !token.valid?
      # rubocop:disable Metrics/LineLength
      # Linux-styleguide approach to long lines: in general, no, except with
      # error messages, which should be on one line so they can be grepped
      Rails.logger.debug("This token is invalid, but we're not sure why: #{token.inspect}")
      render json: {
        'errors' => [{
          'title' => 'Just-generated JWT token is invalid',
          'detail' => 'Not sure why the token would be invalid but there weren\'t any other errors. See logs.'
        }]
      }, status: 401 # Unauthorized
      # rubocop:enable Metrics/LineLength
    else
      render json: {
        'data' => {
          'token' => token.jwt,
          'expires_at' => token.expires.to_i
        }
      }
    end
  end
end
