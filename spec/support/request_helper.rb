# A helper to abstract away all of that repetitious JSON parsing.
# With the help of this helper, we can skip the explicit call to 'JSON.parse' to each individual test, 
# and instead refer to the parsed response via the method call, 'json'.

module Requests  
  module JsonHelpers
    def json
      JSON.parse(last_response.body)
    end
  end
end  