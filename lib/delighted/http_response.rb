module Delighted
  class HTTPResponse
    attr_reader :status_code, :headers, :body

    def initialize(raw_status_code, raw_headers, raw_body)
      @status_code = raw_status_code.to_i
      @headers = raw_headers
      @body = raw_body
    end

    def content_type
      get_header_value("content-type")
    end

    def retry_after
      if value = get_header_value("retry-after")
        value.to_i
      end
    end

    private

    # Get value from header. Takes care of:
    #
    # - Unwrapping multiple values.
    # - Handling casing difference in header name.
    def get_header_value(key)
      _key, value = @headers.detect { |k, _v| k.to_s.downcase == key.to_s.downcase }

      if value
        values = Utils.wrap_array(value)

        if values.size == 1
          values[0]
        else
          values
        end
      end
    end
  end
end
