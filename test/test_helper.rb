require 'delighted'
require 'minitest/autorun'
require 'mocha/setup'

class Delighted::TestCase < Minitest::Test
  include Mocha

  def setup
    super
    Delighted.shared_client = Delighted::Client.new(api_key: '123abc', http_adapter: mock_http_adapter)
  end

  def mock_http_adapter
    @mock ||= mock
  end
end
