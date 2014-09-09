require 'json'

module Delighted
  #
  # Class that satisfies the interface of HTTPAdapter
  # but does not actually make HTTP requests
  #
  class MockHTTPAdapter < HTTPAdapter
    def request(method, uri, headers, data = nil)
      response = self.build_response(method, headers, data)
      HTTPResponse.new(response.code, response.headers, response.body)
    end

    #
    # Builds an appropriate response we can pass on to the rest of the
    #
    def build_response(method, headers, data)
      case method
      when :delete
        MockDelete.new(headers, data)
      when :get
        MockGet.new(headers, data)
      when :post
        MockPost.new(headers, data)
      when :put
        MockPut.new(headers, data)
      else
        raise ArgumentError.new("#{method} is not a valid HTTP verb")
      end
    end
  end

  #
  # Superclass for requests
  #
  class MockRequest

    attr_reader :headers, :data

    #
    # Constructor
    #
    # @param headers [Hash]
    # @param data [Hash, nil]
    #
    def initialize(headers, data)
      @headers, @data = headers, JSON.load(data || '{}')
    end

    #
    # Default to a blank body and the headers we sent
    #
    def body
      ""
    end

    #
    # Default to 200 (Success)
    #
    # @return [Integer]
    def code
      200
    end

    protected

    #
    # Helper method to generate a unique ID
    #
    # @return [Integer]
    def next_id
      @counter ||= 0
      @counter += 1
    end
  end

  #
  # Fake DELETE request
  #
  class MockDelete < MockRequest
    #
    # Implementation of body
    #
    # @return [String]
    def body
      JSON.dump(ok: true)
    end
  end

  #
  # Handles GET requests
  #
  class MockGet < MockRequest
  end

  #
  # Handles POST requests
  #
  class MockPost < MockRequest
    #
    # Constructor
    #
    def initialize(headers, data = '{}')
      super(headers, data)
    end

    #
    # Implementation of #body
    #
    # @return [String]
    def body
      JSON.dump(@data.merge(id: self.next_id))
    end

    #
    # Implementation of #code
    #
    # @return [Integer] 201 (Created)
    def code
      201
    end
  end

  #
  # Fake PUT request
  #
  class MockPut < MockRequest
    #
    # Implementation of body
    #
    # @return [String]
    def body
      JSON.dump(@data || {})
    end
  end

end