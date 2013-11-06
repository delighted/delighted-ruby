module Delighted
  class HTTPResponse
    attr_reader :status_code, :headers, :body

    def initialize(raw_status_code, raw_headers, raw_body)
      @status_code = raw_status_code.to_i
      @headers = raw_headers
      @body = raw_body
    end

    def content_type
      @headers.values_at('content-type', 'Content-Type')[0]
    end
  end
end
