require 'test_helper'

class Delighted::ClientTest < Delighted::TestCase
  def test_instantiating_client_requires_api_key
    assert_raises(ArgumentError) { Delighted::Client.new }
    Delighted::Client.new(:api_key => '123abc')
  end

  def test_handles_rate_limited_response
    response = Delighted::HTTPResponse.new(429, { "Retry-After" => "10" }, Delighted::JSON.dump({ :status => 429, :message => "Too Many Requests" }
))
    mock_http_adapter.stubs(:request).returns(response)

    assert_raises(Delighted::RateLimitedError) do
      begin
        Delighted.shared_client.get_json("/foo")
      rescue Delighted::RateLimitedError => e
        assert_equal 10, e.retry_after
        raise
      end
    end
  end
end

class Delighted::MetricsTest < Delighted::TestCase
  def test_retrieving_metrics
    uri = URI.parse("https://api.delightedapp.com/v1/metrics")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump({ :nps => 10 }))
    mock_http_adapter.expects(:request).with(:get, uri, headers).once.returns(response)

    metrics = Delighted::Metrics.retrieve
    assert_kind_of Delighted::Metrics, metrics
    assert_equal({ :nps => 10 }, metrics.to_hash)
    assert_equal 10, metrics.nps
    assert_raises(NoMethodError) { metrics.id }
  end
end

class Delighted::PeopleTest < Delighted::TestCase
  def test_creating_or_updating_a_person
    uri = URI.parse("https://api.delightedapp.com/v1/people")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'Content-Type' => 'application/json', 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    data = Delighted::JSON.dump({ :email => 'foo@bar.com' })
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump({ :id => '123', :email => 'foo@bar.com' }))
    mock_http_adapter.expects(:request).with(:post, uri, headers, data).once.returns(response)

    person = Delighted::Person.create(:email => 'foo@bar.com')
    assert_kind_of Delighted::Person, person
    assert_equal({ :email => 'foo@bar.com' }, person.to_hash)
    assert_equal 'foo@bar.com', person.email
    assert_equal '123', person.id
  end

  def test_unsubscribing_a_person
    person_email = 'person@example.com'
    uri = URI.parse('https://api.delightedapp.com/v1/unsubscribes')
    headers = {
      'Authorization' => @auth_header,
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}"
    }
    data = Delighted::JSON.dump(:person_email => person_email)
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump({ :ok => true }))
    mock_http_adapter.expects(:request).
      with(:post, uri, headers, data).once.
      returns(response)

    survey_response = Delighted::Unsubscribe.create(:person_email => person_email)
  end

  def test_deleting_pending_survey_requests_for_a_person
    uri = URI.parse("https://api.delightedapp.com/v1/people/foo%40bar.com/survey_requests/pending")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'Content-Type' => 'application/json', 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump({ :ok => true }))
    mock_http_adapter.expects(:request).with(:delete, uri.to_s, headers, nil).once.returns(response)

    result = Delighted::SurveyRequest.delete_pending(:person_email => "foo@bar.com")
    assert_kind_of Hash, result
    assert_equal({ :ok => true }, result)
  end

  def test_deleting_a_person_by_id
    uri = URI.parse("https://api.delightedapp.com/v1/people/57")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'Content-Type' => 'application/json', 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    response = Delighted::HTTPResponse.new(202, {}, Delighted::JSON.dump({ :ok => true }))
    mock_http_adapter.expects(:request).with(:delete, uri.to_s, headers, nil).once.returns(response)

    result = Delighted::Person.delete(:id => 57)
    assert_kind_of Hash, result
    assert_equal({ :ok => true }, result)
  end

  def test_deleting_a_person_by_email
    uri = URI.parse("https://api.delightedapp.com/v1/people/email%3Afoo%40bar.com")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'Content-Type' => 'application/json', 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    response = Delighted::HTTPResponse.new(202, {}, Delighted::JSON.dump({ :ok => true }))
    mock_http_adapter.expects(:request).with(:delete, uri.to_s, headers, nil).once.returns(response)

    result = Delighted::Person.delete(:email => "foo@bar.com")
    assert_kind_of Hash, result
    assert_equal({ :ok => true }, result)
  end

  def test_deleting_a_person_by_phone_number
    uri = URI.parse("https://api.delightedapp.com/v1/people/phone_number%3A%2B14155551212")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'Content-Type' => 'application/json', 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    response = Delighted::HTTPResponse.new(202, {}, Delighted::JSON.dump({ :ok => true }))
    mock_http_adapter.expects(:request).with(:delete, uri.to_s, headers, nil).once.returns(response)

    result = Delighted::Person.delete(:phone_number => "+14155551212")
    assert_kind_of Hash, result
    assert_equal({ :ok => true }, result)
  end
end

class Delighted::SurveyResponseTest < Delighted::TestCase
  def test_creating_a_survey_response
    uri = URI.parse("https://api.delightedapp.com/v1/survey_responses")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'Content-Type' => 'application/json', 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    data = OrderedHash.new
    data[:person] = '123'
    data[:score] = 10
    data = Delighted::JSON.dump(data)
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump({ :id => '456', :person => '123', :score => 10 }))
    mock_http_adapter.expects(:request).with(:post, uri, headers, data).once.returns(response)

    survey_response = Delighted::SurveyResponse.create(:person => '123', :score => 10)
    assert_kind_of Delighted::SurveyResponse, survey_response
    assert_equal({ :person => '123', :score => 10 }, survey_response.to_hash)
    assert_equal '123', survey_response.person
    assert_equal 10, survey_response.score
    assert_equal '456', survey_response.id
  end

  def test_retrieving_a_survey_response
    uri = URI.parse("https://api.delightedapp.com/v1/survey_responses/456")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump({ :id => '456', :person => '123', :score => 10 }))
    mock_http_adapter.expects(:request).with(:get, uri, headers).once.returns(response)

    survey_response = Delighted::SurveyResponse.retrieve('456')
    assert_kind_of Delighted::SurveyResponse, survey_response
    assert_equal({ :person => '123', :score => 10 }, survey_response.to_hash)
    assert_equal '123', survey_response.person
    assert_equal 10, survey_response.score
    assert_equal '456', survey_response.id
  end

  def test_retrieving_a_survey_response_expand_person
    uri = URI.parse("https://api.delightedapp.com/v1/survey_responses/456?expand%5B%5D=person")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump({ :id => '456', :person => { :id => '123', :email => 'foo@bar.com' }, :score => 10 }))
    mock_http_adapter.expects(:request).with(:get, uri, headers).once.returns(response)

    survey_response = Delighted::SurveyResponse.retrieve('456', :expand => ['person'])
    assert_kind_of Delighted::SurveyResponse, survey_response
    assert_equal({ :person => '123', :score => 10 }, survey_response.to_hash)
    assert_kind_of Delighted::Person, survey_response.person
    assert_equal '123', survey_response.person.id
    assert_equal({ :email => 'foo@bar.com' }, survey_response.person.to_hash)
    assert_equal 10, survey_response.score
    assert_equal '456', survey_response.id
  end

  def test_updating_a_survey_response
    uri = URI.parse("https://api.delightedapp.com/v1/survey_responses/456")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'Content-Type' => 'application/json', 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    data = OrderedHash.new
    data[:person] = '123'
    data[:score] = 10
    data = Delighted::JSON.dump(data)
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump({ :id => '456', :person => '123', :score => 10 }))
    mock_http_adapter.expects(:request).with(:put, uri, headers, data).once.returns(response)

    survey_response = Delighted::SurveyResponse.new(:id => '456', :person => '321', :score => 1)
    survey_response.person = '123'
    survey_response.score = 10
    assert_kind_of Delighted::SurveyResponse, survey_response.save
    assert_equal({ :person => '123', :score => 10 }, survey_response.to_hash)
    assert_equal '123', survey_response.person
    assert_equal 10, survey_response.score
    assert_equal '456', survey_response.id
  end

  def test_listing_all_survey_responses
    uri = URI.parse("https://api.delightedapp.com/v1/survey_responses?order=desc")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump([{ :id => '123', :comment => 'One' }, { :id => '456', :comment => 'Two' }]))
    mock_http_adapter.expects(:request).with(:get, uri, headers).once.returns(response)

    survey_responses = Delighted::SurveyResponse.all(:order => 'desc')
    assert_kind_of Delighted::EnumerableResourceCollection, survey_responses
    assert_kind_of Delighted::SurveyResponse, survey_responses[0]
    assert_equal({ :comment => 'One' }, survey_responses[0].to_hash)
    assert_equal 'One', survey_responses[0].comment
    assert_equal '123', survey_responses[0].id
    assert_kind_of Delighted::SurveyResponse, survey_responses[1]
    assert_equal({ :comment => 'Two' }, survey_responses[1].to_hash)
    assert_equal 'Two', survey_responses[1].comment
    assert_equal '456', survey_responses[1].id
  end

  def test_listing_all_survey_responses_expand_person
    uri = URI.parse("https://api.delightedapp.com/v1/survey_responses?expand%5B%5D=person")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump([{ :id => '123', :comment => 'One', :person => { :id => '123', :email => 'foo@bar.com' } }, { :id => '456', :comment => 'Two', :person => { :id => '123', :email => 'foo@bar.com' } }]))
    mock_http_adapter.expects(:request).with(:get, uri, headers).once.returns(response)

    survey_responses = Delighted::SurveyResponse.all(:expand => ['person'])
    assert_kind_of Delighted::EnumerableResourceCollection, survey_responses
    assert_kind_of Delighted::SurveyResponse, survey_responses[0]
    assert_equal({ :person => '123', :comment => 'One' }, survey_responses[0].to_hash)
    assert_equal 'One', survey_responses[0].comment
    assert_equal '123', survey_responses[0].id
    assert_kind_of Delighted::Person, survey_responses[0].person
    assert_equal({ :email => 'foo@bar.com' }, survey_responses[0].person.to_hash)
    assert_kind_of Delighted::SurveyResponse, survey_responses[1]
    assert_equal({ :person => '123', :comment => 'Two' }, survey_responses[1].to_hash)
    assert_equal 'Two', survey_responses[1].comment
    assert_equal '456', survey_responses[1].id
    assert_kind_of Delighted::Person, survey_responses[1].person
    assert_equal({ :email => 'foo@bar.com' }, survey_responses[1].person.to_hash)
  end
end

class Delighted::UnsubscribesTest < Delighted::TestCase
  def test_listing_unsubscribes
    uri = URI.parse("https://api.delightedapp.com/v1/unsubscribes")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    example_unsub = {:person_id => '4945', :email => 'foo@example.com', :name => nil, :unsubscribed_at => 1440621400}
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump([example_unsub]))
    mock_http_adapter.expects(:request).with(:get, uri, headers).once.returns(response)

    unsubscribes = Delighted::Unsubscribe.all
    assert_equal 1, unsubscribes.size
    first_unsub = unsubscribes.first
    assert_kind_of Delighted::Unsubscribe, first_unsub
    assert_equal '4945', first_unsub.person_id
    assert_equal example_unsub, first_unsub.to_hash
  end
end


class Delighted::BouncesTest < Delighted::TestCase
  def test_listing_bounces
    uri = URI.parse("https://api.delightedapp.com/v1/bounces")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    example_bounce = {:person_id => '4945', :email => 'foo@example.com', :name => nil, :bounced_at => 1440621400}
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump([example_bounce]))
    mock_http_adapter.expects(:request).with(:get, uri, headers).once.returns(response)

    bounces = Delighted::Bounce.all
    assert_equal 1, bounces.size
    first_bounce = bounces.first
    assert_kind_of Delighted::Bounce, first_bounce
    assert_equal '4945', first_bounce.person_id
    assert_equal example_bounce, first_bounce.to_hash
  end
end

