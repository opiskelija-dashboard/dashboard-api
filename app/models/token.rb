class Token
  require 'jwt'
  require 'json'
  require 'net/http' # since ruby 2.4.1 "require 'net/https'" isn't necessary

  JWT_HASH_ALGO = 'HS256'
  @@jwt_secret = Rails.configuration.jwt_secret;
  @@verify_tmc_creds = Rails.configuration.jwt_verify_tmc_credentials;

  def initialize
    @errors = Array.new
    @invalidated = true
    @tested = false
    @expires = 0
    @username = ""
    @tmc_token = ""
    @jwt = ""
  end

  def self.new_from_credentials(username, tmc_access_token)
    token = Token.new
    token.initialize_from_credentials(username, tmc_access_token)
    return token
  end

  def self.new_from_jwt_string(jwt)
    token = Token.new
    token.initialize_from_jwt_string(jwt)
    return token
  end

  def initialize_from_credentials(username, tmc_access_token, verify_creds = @@verify_tmc_creds)
    @username = username
    @tmc_token = tmc_access_token
    @expires = Time.now + 86400
    @tested = false
    @invalidated = false
    @jwt_string = make_jwt

    if (verify_creds)
      verification_result = verify_given_credentials(@username, @tmc_token)
      if (verification_result == true)
        @tested = true
      else
        # We invalidate the token when it was checked for validity but didn't
        # pass the check. We don't invalidate it if it wasn't supposed to be
        # checked in the first place, which is why this statement is here
        # and not, for instance, in an else-branch of if(verify_creds).
        @invalidated = true
        # verify_given_credentials will set an error, so we don't need
        # to do so here.
      end
    end
  end

  def initialize_from_jwt_string(jwt)
    @jwt_string = jwt

    decoded_token = JWT.decode(jwt, @@jwt_secret, true, {:algorithm => JWT_HASH_ALGO})
    # The format of what JWT.decode returns:
    # [ {"tmcusr"=>  "username", "tmctok"=>"ABCD", "exp"=>1500000000},
    #   {"typ"=>"JWT", "alg"=>"HS256"} ]
    # Rails.logger.debug(decoded_token.inspect)

    token_payload = decoded_token[0]
    if (!token_payload.nil?)
      @username = token_payload["tmcusr"]
      @tmc_token = token_payload["tmctok"]
      @expires = token_payload["exp"]
      @invalidated = self.expired?
      @tested = @@verify_tmc_creds
    end
  rescue JWT::VerificationError
    error = {
      "title" => "Token verification error",
      "detail" => "The token is invalid, corrupt, or maliciously created, as it does not pass signature verification.",
    }
    @errors.push(error)
    @invalidated = true
    @tested = false
  rescue JWT::DecodeError
    error = {
      "title" => "Malformed token",
      "detail" => "The JWT token given is incorrectly formed and cannot be decoded.",
    }
    @errors.push(error)
    @invalidated = true
    @tested = false
  end


  def username
    @username
  end

  def tmc_token
    @tmc_token
  end

  def expires
    @expires
  end

  def jwt
    @jwt_string
  end

  def errors?
    return !(@errors.empty?)
  end

  def errors
    return @errors
  end

  def valid?
    # The class variable @invalidated exists because we might want to define
    # the token as invalid despite it not having expired yet; for instance, if
    # signature verification has failed, or if the application configuration
    # demands usernames and access tokens are tested and the given ones have
    # failed such a test.
    return !(@invalidated | self.expired?)
  end

  # "Tested" is different from "valid" in that a token is valid if it isn't
  # expired or hasn't been invalidated for another reason, but is tested
  # only if:
  # 1) When the Token object was created with new_from_credentials, the
  #    config setting Rails.configuration.jwt_verify_tmc_credentials is true,
  #    and the "given credentials" were successfully used to log in to the
  #    TMC server.
  # 2) When the Token object was created with new_from_jwt_string, the config
  #    setting Rails.configuration.jwt_verify_tmc_credentials is true. The
  #    assumption is that if jwt_verify_tmc_credentials is true now, it was
  #    true when the JWT token was created and signed, and the TMC credentials
  #    contained within the JWT token were successfully used to log in to the
  #    TMC server back then.
  # So, for development purposes, a token that isn't tested but is valid
  # might be acceptable, but a token that isn't valid is never OK.
  def tested?
    @tested
  end


  def expired?
    now = Time.now
    # We add one minute to expiry time to account for possible clock drift,
    # as allowed by RFC 7519 (the JWT standard)
    exp = Time.at(@expires) + 60
    # (a<=>b)>0 because Time doesn't define > itself
    expired = (now <=> exp) > 0
    if (expired)
      error = {
        :title => "Expired JWT token",
        :detail => "The expiration time specified in the JWT token body has elapsed."
      }
      # Let's not push a new identical error on the error pile.
      unless (@errors.include?(error))
        @errors.push(error)
      end
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


  private


  def make_jwt
    token_payload = {
      "tmcusr" => @username,
      "tmctok" => @tmc_token,
      "exp" => @expires.to_i
    }
    jwt_string = JWT.encode(token_payload, @@jwt_secret, JWT_HASH_ALGO)
    return jwt_string
  end


  def verify_given_credentials(given_username, tmc_access_token)
    api_call_result = do_tmc_api_get('/users/current', tmc_access_token);

    if (api_call_result[:success])
      response_hash = api_call_result[:body]
      # The TMC server would have returned JSON of this format:
      # {"id":1234,"username":"asdf","email":"asdf@asdf","administrator":false}
      # and response_hash would be the Ruby equivalent of this.
      returned_username = response_hash['username'];
      if (given_username != returned_username)
        error = {
          "title" => "Credential verification failed",
          "detail" => "The given TMC credentials were tested, and the result was negative: the given username does not match the username returned by the TMC server."
        }
        @errors.push(error)
        return false;
      else
        return true;
      end
    else
      error = {
        "title" => "Unable to verify credentials",
        "detail" => "Verification of the given TMC credentials failed when accessing the TMC server. (Perhaps the given TMC access token is invalid.) Server response: " + api_call_result[:code] + "\n" + api_call_result[:body]
      }
      @errors.push(error)
      return false;
    end
  end

end