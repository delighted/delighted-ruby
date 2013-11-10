require 'net/https'
require 'uri'
require 'cgi'
require 'multi_json'
require 'set'
require 'thread'

require 'delighted/utils'
require 'delighted/json'

require 'delighted/enumerable_resource_collection'
require 'delighted/resource'
require 'delighted/operations/all'
require 'delighted/operations/create'
require 'delighted/operations/retrieve'

require 'delighted/resources/metrics'
require 'delighted/resources/person'
require 'delighted/resources/survey_responses'

require 'delighted/errors'
require 'delighted/http_response'
require 'delighted/http_adapter'
require 'delighted/client'

module Delighted
  @mutex = Mutex.new

  class << self
    attr_accessor :api_key, :api_base_url, :http_adapter
    attr_writer :shared_client

    def shared_client
      @mutex.synchronize do
        @shared_client ||= Client.new(api_key: api_key, api_base_url: api_base_url, http_adapter: http_adapter)
      end
    end
  end
end
