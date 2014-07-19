module Delighted
  class HTTPAdapter
    REQUEST_CLASSES = {
      :get => Net::HTTP::Get,
      :post => Net::HTTP::Post,
      :delete => Net::HTTP::Delete,
      :put => Net::HTTP::Put
    }

    def request(method, uri, headers = {}, data = nil)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      request = REQUEST_CLASSES[method].new(uri.request_uri)
      headers.each { |k,v| request[k] = v }
      request.body = data

      response = http.request(request)
      HTTPResponse.new(response.code, response.to_hash, response.body)
    end
  end
end
