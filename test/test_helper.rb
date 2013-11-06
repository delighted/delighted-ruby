require 'delighted'
require 'minitest/autorun'
require 'mocha/setup'

class Delighted::TestCase < Minitest::Test
  include Mocha

  def mock_http_adapter
    @mock ||= mock
  end
end
