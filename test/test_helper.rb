require 'delighted'
require 'minitest/autorun'
require 'mocha/setup'

class Delighted::TestCase < Minitest::Test
  include Mocha

  def setup
    super
    Delighted.api_key = '123abc'
    Delighted.http_adapter = mock_http_adapter
  end

  def teardown
    #
    # Clear our our shared client and all settings
    #
    Delighted.shared_client = nil
    Delighted.api_key = nil
    Delighted.http_adapter = nil
  end

  def mock_http_adapter
    @mock ||= mock
  end
end
