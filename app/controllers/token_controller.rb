class TokenController < ApplicationController
  require 'jwt'

  skip_before_action :authenticate_request

  def newtoken
    tmc_username = params[:tmc_username]
    tmc_access_token = params[:tmc_access_token]

    # here we would try logging in to the TMC server with the given
    # access token, fetching user information from the server, and checking
    # that the returned username matches the given username.

    usernames_match = true

    if (usernames_match)
      expiry = 24.hours.from_now.to_i
      # in proper use we'd fetch the secret from a conf file or
      # environment variable instead of hardcoding it into the program
      secret = 'secret'
      token_payload = { tmcusr: tmc_username,
        tmctok: tmc_access_token,
        exp: expiry }
      token_string = JWT.encode(token_payload, secret, 'HS256')
      render json: {
        data: {
          token: token_string
        }
      }
    end
  end

end