require 'test_helper'

class Delighted::MockHTTPAdapterTest < Delighted::TestCase

  def setup
    super
    Delighted.api_key = '123abc'
    Delighted.test_mode = true
  end

  def teardown
    super
    Delighted.api_key = nil
    Delighted.test_mode = false
  end

  def adapter
    @adapter ||= Delighted::MockHTTPAdapter.new
  end

  def test_adapter_is_mock
    assert_kind_of(
      Delighted::MockHTTPAdapter,
      Delighted.shared_client.http_adapter
    )
  end

  def test_get
    response = adapter.request(:get, '/a/b/c', {})
    assert_kind_of(
      Delighted::HTTPResponse,
      response
    )
  end

  def test_delete
    response = adapter.request(:delete, '/a/b/c', {})
    assert_kind_of(
      Delighted::HTTPResponse,
      response
    )
  end

  def test_post
    response = adapter.request(
      :post,
      '/a/b/c',
      {},
      JSON.dump({ email: 'test@test.com'})
    )
    assert_kind_of(
      Delighted::HTTPResponse,
      response
    )
    assert_equal(
      ::JSON.load(response.body)['email'],
      'test@test.com',
    )
  end

  def test_put
    response = adapter.request(
      :put,
      '/a/b/c',
      {},
      JSON.dump({ email: 'test@test.com'})
    )
    assert_kind_of(
      Delighted::HTTPResponse,
      response
    )
    assert_equal(
      ::JSON.load(response.body)['email'],
      'test@test.com',
    )
  end

  def test_create_person
    person = Delighted::Person.create(email: 'test@test.com')
    assert_equal(person.email, 'test@test.com')
    refute_nil(person.id)
  end

end