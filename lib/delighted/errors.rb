module Delighted
  class Error < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def to_s
      "#{@response.status_code}: #{@response.body}"
    end
  end

  class AuthenticationError < Error
    # 401, api auth missing or incorrect
  end

  class UnsupportedFormatRequestedError < Error
    # 406, invalid format in Accept header
  end

  class ResourceValidationError < Error
    # 422, validation errors
  end

  class RateLimitedError < Error
    # 429, rate limited

    def retry_after
      response.retry_after
    end
  end

  class GeneralAPIError < Error
    # 500, general/unknown error
  end

  class ServiceUnavailableError < Error
    # 503, maintenance or overloaded
  end

  class PaginationError < StandardError
    # e.g. pagination completed
  end
end
