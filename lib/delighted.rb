require 'net/https'
require 'uri'
require 'cgi'
require 'multi_json'
require 'set'
require 'thread'

require 'delighted/version'
require 'delighted/utils'
require 'delighted/json'

require 'delighted/enumerable_resource_collection'
require 'delighted/resource'
require 'delighted/operations/all'
require 'delighted/operations/create'
require 'delighted/operations/retrieve'
require 'delighted/operations/update'

require 'delighted/resources/metrics'
require 'delighted/resources/person'
require 'delighted/resources/survey_request'
require 'delighted/resources/survey_response'
require 'delighted/resources/unsubscribe'

require 'delighted/errors'
require 'delighted/http_response'
require 'delighted/http_adapter'
require 'delighted/mock_http_adapter'
require 'delighted/client'

module Delighted
  @mutex = Mutex.new

  class << self
    attr_accessor :api_key, :api_base_url
    attr_writer :http_adapter, :shared_client, :test_mode

    #
    # We override the setting to return a MockHTTPAdapter
    # if we are in test mode
    #
    def http_adapter
      if self.test_mode?
        self.mock_http_adapter
      else
        @http_adapter
      end
    end

    def shared_client
      @mutex.synchronize do
        @shared_client ||= Client.new(:api_key => api_key, :api_base_url => api_base_url, :http_adapter => http_adapter)
      end
    end

    #
    # Are we currently in test mode?
    #
    # @return [Boolean]
    def test_mode
      @test_mode ||= false
    end
    alias_method :test_mode?, :test_mode

    protected

    #
    # Hold on to an instance of a MockHTTPAdapter
    #
    def mock_http_adapter
      @mock_http_adapter ||= ::Delighted::MockHTTPAdapter.new
    end

  end
end
