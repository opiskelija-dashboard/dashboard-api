class TokensController < ApplicationController
  require 'jwt'
  require 'net/http' # since ruby 2.4.1 "require 'net/https'" isn't necessary
  require 'json'

  skip_before_action :authenticate_request

  def newtoken
    Rails.logger.info("JWT secret for this session: \"" + Rails.configuration.jwt_secret + '"')

    tmc_username = params[:tmc_username]
    tmc_access_token = params[:tmc_access_token]

    # here we would try logging in to the TMC server with the given
    # access token, fetching user information from the server, and checking
    # that the returned username matches the given username.

    usernames_match = verify_given_credentials(tmc_username, tmc_access_token)

    if (usernames_match)
      expiry = 24.hours.from_now.to_i
      secret = Rails.configuration.jwt_secret
      token_payload = {
        tmcusr: tmc_username,
        tmctok: tmc_access_token,
        exp: expiry
      }
      token_string = JWT.encode(token_payload, secret, 'HS256')
      render json: {
        data: {
          token: token_string
        }
      }
    else
      render json: { "errors" => # json:api format
          [{
            "title" => "Invalid Credentials",
            "detail" => "Either: you did not pass a tmc_username and tmc_access_token; the tmc_access_token did not work for accessing the TMC API; or the tmc_username did not match that returned by the TMC API when asked with the tmc_access_token.",
          }]
        },
        status: 401 # unauthorized
    end
  end

  def verify_given_credentials(given_username, acctok)
    api_call_result = do_tmc_api_get('/users/current', acctok);

    if (api_call_result[:success])
      response_hash = api_call_result[:body]
      # The TMC server would have returned JSON of this format:
      # {"id":1234,"username":"asdf","email":"asdf@asdf","administrator":false}
      # and response_hash would be the Ruby equivalent of this.
      returned_username = response_hash['username'];
      if (given_username != returned_username)
        Rails.logger.debug("verify_given_credentials: given_username != returned_username");
        return false;
      else
        return true;
      end
    else
      Rails.logger.debug("verify_given_credentials: do_tmc_api_get didn't work");
      return false;
    end

  end

  # returns a hash structured thusly:
  # { :success => true/false, :code => <http response code>, :body => <decoded JSON response from api> }
  def do_tmc_api_get(endpoint, access_token)
    tmc_api_base_address = Rails.configuration.tmc_api_base_address
    tmc_api_endpoint = "/users/current"
    full_api_call_address = tmc_api_base_address + tmc_api_endpoint

    authtokenstring = 'Bearer ' + access_token

    uri = URI.parse(full_api_call_address)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = authtokenstring
    #Rails.logger.debug("HTTP::Get object's headers:");
    #request.each_header { |h, v| Rails.logger.debug("\t" + h + ": " + v) }

    response = Net::HTTP.start(uri.hostname, uri.port,
        :use_ssl => true, :verify_mode => OpenSSL::SSL::VERIFY_PEER) { |http|
      http.request(request)
    }

    if (response.code.to_s == "200")
      response_hash = JSON.parse(response.body);
      return_hash = { :success => true, :code => response.code, :body => response_hash }
      return return_hash
    else
      Rails.logger.debug("do_tmc_api_get: GET to " + full_api_call_address + " returned code " + response.code.inspect + " (!= 200). Response body: " + response.body);
      return_hash = { :success => false, :code => response.code, :body => response.body}
    end
  end

end
