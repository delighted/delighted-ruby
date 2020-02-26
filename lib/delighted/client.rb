module Delighted
  class Client
    DEFAULT_API_BASE_URL = "https://api.delightedapp.com/v1"
    DEFAULT_HTTP_ADAPTER = HTTPAdapter.new
    DEFAULT_ACCEPT_HEADER = "application/json"

    def initialize(opts = {})
      @api_key = opts[:api_key] or raise ArgumentError, "You must provide an API key by setting Delighted.api_key = '123abc' or passing { :api_key => '123abc' } when instantiating Delighted::Client.new"
      @api_base_url = opts[:api_base_url] || DEFAULT_API_BASE_URL
      @http_adapter = opts[:http_adapter] || DEFAULT_HTTP_ADAPTER
    end

    def get_json(path, params = {})
      request_get(path, {params: params})[:json]
    end

    def request_get(path, opts = {})
      accept_header = opts.fetch(:accept_header, DEFAULT_ACCEPT_HEADER)
      params = opts.fetch(:params, {})

      headers = default_headers.dup.merge('Accept' => accept_header)

      path = File.join(@api_base_url, path) unless is_full_url(path)
      uri = URI.parse(path)
      uri.query = Utils.to_query(params) unless params.empty?

      response = @http_adapter.request(:get, uri, headers)
      { json: handle_json_response(response), response: response }
    end

    def post_json(path, params = {})
      headers = default_headers.dup.merge('Accept' => 'application/json', 'Content-Type' => 'application/json')

      uri = URI.parse(File.join(@api_base_url, path))
      data = JSON.dump(params) unless params.empty?

      response = @http_adapter.request(:post, uri, headers, data)
      handle_json_response(response)
    end

    def put_json(path, params = {})
      headers = default_headers.dup.merge('Accept' => 'application/json', 'Content-Type' => 'application/json')

      uri = URI.parse(File.join(@api_base_url, path))
      data = JSON.dump(params) unless params.empty?

      response = @http_adapter.request(:put, uri, headers, data)
      handle_json_response(response)
    end

    def delete_json(path, params = {})
      headers = default_headers.dup.merge('Accept' => 'application/json', 'Content-Type' => 'application/json')

      uri = URI.parse(File.join(@api_base_url, path))
      data = JSON.dump(params) unless params.empty?

      response = @http_adapter.request(:delete, uri, headers, data)
      handle_json_response(response)
    end

    private

    def handle_json_response(response)
      case response.status_code
      when 200, 201, 202
        Utils.symbolize_keys(JSON.load(response.body))
      when 401
        raise AuthenticationError, response
      when 406
        raise UnsupportedFormatRequestedError, response
      when 422
        raise ResourceValidationError, response
      when 429
        raise RateLimitedError, response
      when 503
        raise ServiceUnavailableError, response
      else
        raise GeneralAPIError, response
      end
    end

    def default_headers
      @default_headers ||= {
        'Authorization' => "Basic #{["#{@api_key}:"].pack('m').chomp}",
        'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}"
      }.freeze
    end

    def is_full_url(url)
      !!(URI::regexp(%w(http https)) =~ url)
    end
  end
end
