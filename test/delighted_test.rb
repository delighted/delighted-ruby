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
  def test_listing_people_auto_paginate
    uri = URI.parse("https://api.delightedapp.com/v1/people")
    uri_next = URI.parse("https://api.delightedapp.com/v1/people.json?page_info=123456789")
    headers = { "Authorization" => @auth_header, "Accept" => "application/json", "User-Agent" => "Delighted RubyGem #{Delighted::VERSION}" }

    # First request mock
    example_person1 = {:person_id => "4945", :email => "foo@example.com", :name => "Gold"}
    example_person2 = {:person_id => "4946", :email => "foo+2@example.com", :name => "Silver"}
    response = Delighted::HTTPResponse.new(200, {"Link" => "<#{uri_next}>; rel=\"next\""}, Delighted::JSON.dump([example_person1,example_person2]))
    mock_http_adapter.expects(:request).with(:get, uri, headers).once.returns(response)

    # Next request mock
    example_person_next = {:person_id => "4947", :email => "foo+3@example.com", :name => "Bronze"}
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump([example_person_next]))
    mock_http_adapter.expects(:request).with(:get, uri_next, headers).once.returns(response)

    persons_all = []
    Delighted::Person.list.auto_paging_each do |p|
      persons_all << p
    end

    assert_equal 3, persons_all.size

    first_person = persons_all[0]
    assert_kind_of Delighted::Person, first_person
    assert_equal "Gold", first_person.name
    assert_equal example_person1, first_person.to_hash
    second_person = persons_all[1]
    assert_kind_of Delighted::Person, second_person
    assert_equal "Silver", second_person.name
    assert_equal example_person2, second_person.to_hash
    third_person = persons_all[2]
    assert_kind_of Delighted::Person, third_person
    assert_equal "Bronze", third_person.name
    assert_equal example_person_next, third_person.to_hash
  end

  def test_listing_people_rate_limited
    uri = URI.parse("https://api.delightedapp.com/v1/people")
    uri_next = URI.parse("https://api.delightedapp.com/v1/people.json?page_info=123456789")
    headers = { "Authorization" => @auth_header, "Accept" => "application/json", "User-Agent" => "Delighted RubyGem #{Delighted::VERSION}" }

    # First request mock
    example_person1 = {:person_id => "4945", :email => "foo@example.com", :name => "Gold"}
    response = Delighted::HTTPResponse.new(200, {"Link" => "<#{uri_next}>; rel=\"next\""}, Delighted::JSON.dump([example_person1]))
    mock_http_adapter.expects(:request).with(:get, uri, headers).once.returns(response)

    # Next rate limited request mock
    response = Delighted::HTTPResponse.new(429, { "Retry-After" => "10" }, {})
    mock_http_adapter.expects(:request).with(:get, uri_next, headers).once.returns(response)

    persons_all = []
    exception = assert_raises Delighted::RateLimitedError do
      Delighted::Person.list.auto_paging_each({ :auto_handle_rate_limits => false }) do |p|
        persons_all << p
      end
    end

    assert_equal "10", exception.response.headers['Retry-After']

    assert_equal 1, persons_all.size
    first_person = persons_all[0]
    assert_kind_of Delighted::Person, first_person
    assert_equal "Gold", first_person.name
    assert_equal example_person1, first_person.to_hash
  end

  def test_listing_people_auto_handle_rate_limits
    uri = URI.parse("https://api.delightedapp.com/v1/people")
    uri_next = URI.parse("https://api.delightedapp.com/v1/people.json?page_info=123456789")
    headers = { "Authorization" => @auth_header, "Accept" => "application/json", "User-Agent" => "Delighted RubyGem #{Delighted::VERSION}" }

    # First request mock
    example_person1 = {:person_id => "4945", :email => "foo@example.com", :name => "Gold"}
    response = Delighted::HTTPResponse.new(200, {"Link" => "<#{uri_next}>; rel=\"next\""}, Delighted::JSON.dump([example_person1]))
    mock_http_adapter.expects(:request).with(:get, uri, headers).once.returns(response)

    # Next rate limited request mock, then accepted request
    response_rate_limited = Delighted::HTTPResponse.new(429, { "Retry-After" => "3" }, {})
    example_person_next = {:person_id => "4947", :email => "foo+next@example.com", :name => "Silver"}
    response_ok = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump([example_person_next]))
    mock_http_adapter.expects(:request).with(:get, uri_next, headers).twice.returns(response_rate_limited, response_ok)

    persons_all = []
    people = Delighted::Person.list
    people.expects(:sleep).with(3)
    people.auto_paging_each({ :auto_handle_rate_limits => true }) do |p|
      persons_all << p
    end

    assert_equal 2, persons_all.size
    first_person = persons_all[0]
    assert_kind_of Delighted::Person, first_person
    assert_equal "Gold", first_person.name
    assert_equal example_person1, first_person.to_hash
    next_person = persons_all[1]
    assert_kind_of Delighted::Person, next_person
    assert_equal "Silver", next_person.name
    assert_equal example_person_next, next_person.to_hash
  end

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
    mock_http_adapter.expects(:request).with(:delete, uri, headers, nil).once.returns(response)

    result = Delighted::SurveyRequest.delete_pending(:person_email => "foo@bar.com")
    assert_kind_of Hash, result
    assert_equal({ :ok => true }, result)
  end

  def test_deleting_a_person_with_multiple_identifiers
    assert_raises(ArgumentError) { Delighted::Person.delete(:id => 57, :email => "foo@example.com") }
  end

  def test_deleting_a_person_by_id
    uri = URI.parse("https://api.delightedapp.com/v1/people/57")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'Content-Type' => 'application/json', 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    response = Delighted::HTTPResponse.new(202, {}, Delighted::JSON.dump({ :ok => true }))
    mock_http_adapter.expects(:request).with(:delete, uri, headers, nil).once.returns(response)

    result = Delighted::Person.delete(:id => 57)
    assert_kind_of Hash, result
    assert_equal({ :ok => true }, result)
  end

  def test_deleting_a_person_by_email
    uri = URI.parse("https://api.delightedapp.com/v1/people/email%3Afoo%40bar.com")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'Content-Type' => 'application/json', 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    response = Delighted::HTTPResponse.new(202, {}, Delighted::JSON.dump({ :ok => true }))
    mock_http_adapter.expects(:request).with(:delete, uri, headers, nil).once.returns(response)

    result = Delighted::Person.delete(:email => "foo@bar.com")
    assert_kind_of Hash, result
    assert_equal({ :ok => true }, result)
  end

  def test_deleting_a_person_by_phone_number
    uri = URI.parse("https://api.delightedapp.com/v1/people/phone_number%3A%2B14155551212")
    headers = { 'Authorization' => @auth_header, "Accept" => "application/json", 'Content-Type' => 'application/json', 'User-Agent' => "Delighted RubyGem #{Delighted::VERSION}" }
    response = Delighted::HTTPResponse.new(202, {}, Delighted::JSON.dump({ :ok => true }))
    mock_http_adapter.expects(:request).with(:delete, uri, headers, nil).once.returns(response)

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

