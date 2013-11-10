require 'test_helper'

class Delighted::ClientTest < Delighted::TestCase
  def test_instantiating_client_requires_api_key
    assert_raises(ArgumentError) { Delighted::Client.new }
    Delighted::Client.new(:api_key => '123abc')
  end
end

class Delighted::MetricsTest < Delighted::TestCase
  def test_retrieving_metrics
    uri = URI.parse("https://api.delightedapp.com/v1/metrics")
    headers = { 'Authorization' => "Basic #{["123abc:"].pack('m0')}", "Accept" => "application/json" }
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
    headers = { 'Authorization' => "Basic #{["123abc:"].pack('m0')}", "Accept" => "application/json", 'Content-Type' => 'application/json' }
    data = Delighted::JSON.dump({ :email => 'foo@bar.com' })
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump({ :id => '123', :email => 'foo@bar.com' }))
    mock_http_adapter.expects(:request).with(:post, uri, headers, data).once.returns(response)

    person = Delighted::Person.create(:email => 'foo@bar.com')
    assert_kind_of Delighted::Person, person
    assert_equal({ :email => 'foo@bar.com' }, person.to_hash)
    assert_equal 'foo@bar.com', person.email
    assert_equal '123', person.id
  end
end

class Delighted::SurveyResponseTest < Delighted::TestCase
  def test_creating_a_survey_response
    uri = URI.parse("https://api.delightedapp.com/v1/survey_responses")
    headers = { 'Authorization' => "Basic #{["123abc:"].pack('m0')}", "Accept" => "application/json", 'Content-Type' => 'application/json' }
    data = Delighted::JSON.dump({ :person => '123', :score => 10 })
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump({ :id => '456', :person => '123', :score => 10 }))
    mock_http_adapter.expects(:request).with(:post, uri, headers, data).once.returns(response)

    survey_response = Delighted::SurveyResponse.create(:person => '123', :score => 10)
    assert_kind_of Delighted::SurveyResponse, survey_response
    assert_equal({ :person => '123', :score => 10 }, survey_response.to_hash)
    assert_equal '123', survey_response.person
    assert_equal 10, survey_response.score
    assert_equal '456', survey_response.id
  end

  def test_listing_all_survey_responses
    uri = URI.parse("https://api.delightedapp.com/v1/survey_responses")
    headers = { 'Authorization' => "Basic #{["123abc:"].pack('m0')}", "Accept" => "application/json" }
    response = Delighted::HTTPResponse.new(200, {}, Delighted::JSON.dump([{ :id => '123', :comment => 'One' }, { :id => '456', :comment => 'Two' }]))
    mock_http_adapter.expects(:request).with(:get, uri, headers).once.returns(response)

    survey_responses = Delighted::SurveyResponse.all
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
end
