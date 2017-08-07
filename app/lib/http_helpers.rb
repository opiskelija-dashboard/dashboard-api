class HttpHelpers
  require 'json'
  require 'net/http' # since ruby 2.4.1 "require 'net/https'" isn't necessary

  # returns a hash structured thusly:
  # { :success => true/false,
  #   :code => <http response code>,
  #   :body => <decoded JSON response from api> }
  # If parameter 'access_token' is nil, doesn't set an Authorization header.
  # If parameter 'base_address' is nil, uses rails.configuration.tmc_api_base_address.
  def self.tmc_api_get(endpoint, access_token = nil, base_address = nil)
    if (base_address.nil?)
      base_address = Rails.configuration.tmc_api_base_address
    end
    full_api_call_address = base_address + endpoint

    uri = URI.parse(full_api_call_address)
    request = Net::HTTP::Get.new(uri)

    if (!access_token.nil?)
      authtokenstring = 'Bearer ' + access_token
      request['Authorization'] = authtokenstring
    end

    #request.each_header { |h, v| Rails.logger.debug("\t" + h + ": " + v) }

    use_ssl = !((base_address =~ /^https/).nil?)

    response = Net::HTTP.start(uri.hostname, uri.port,
        :use_ssl => use_ssl, :verify_mode => OpenSSL::SSL::VERIFY_PEER) { |http|
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
