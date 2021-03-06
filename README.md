[![Build Status](https://travis-ci.org/delighted/delighted-ruby.svg?branch=master)](https://travis-ci.org/delighted/delighted-ruby)

# Delighted API Ruby Client

Official Ruby client for the [Delighted API](https://delighted.com/docs/api).

## Installation

Add `gem 'delighted'` to your application's Gemfile, and then run `bundle` to install.

## Configuration

To get started, you need to configure the client with your secret API key. If you're using Rails, you should add the following to new initializer file in `config/initializers/delighted.rb`.

```ruby
require 'delighted'
Delighted.api_key = 'YOUR_API_KEY'
```

For further options, read the [advanced configuration section](#advanced-configuration).

**Note:** Your API key is secret, and you should treat it like a password. You can find your API key in your Delighted account, under *Settings* > *API*.

## Usage

Adding/updating people and scheduling surveys:

```ruby
# Add a new person, and schedule a survey immediately
person1 = Delighted::Person.create(:email => "foo+test1@delighted.com")

# Add a new person, and schedule a survey after 1 minute (60 seconds)
person2 = Delighted::Person.create(:email => "foo+test2@delighted.com",
  :delay => 60)

# Add a new person, but do not schedule a survey
person3 = Delighted::Person.create(:email => "foo+test3@delighted.com",
  :send => false)

# Add a new person with full set of attributes, including a custom question
# product name, and schedule a survey with a 30 second delay
person4 = Delighted::Person.create(:email => "foo+test4@delighted.com",
  :name => "Joe Bloggs", :properties => { :customer_id => 123, :country => "USA",
  :question_product_name => "The London Trench" }, :delay => 30)

# Update an existing person (identified by email), adding a name, without
# scheduling a survey
updated_person1 = Delighted::Person.create(:email => "foo+test1@delighted.com",
  :name => "James Scott", :send => false)
```

Listing all people:

```ruby
# List all people, auto pagination
# Note: Make sure to handle the possible rate limits error
people = Delighted::Person.list
begin
  people.auto_paging_each do |person|
    # Do something with person
  end
rescue Delighted::RateLimitError => e
  # Indicates how long to wait before making this request again
  e.retry_after
  retry
end

# For convenience, this method can use a sleep to automatically handle rate limits
people.auto_paging_each({ auto_handle_rate_limits: true }) do |person|
  # Do something with person
end
```

Unsubscribing people:

```ruby
# Unsubscribe an existing person
Delighted::Unsubscribe.create(:person_email => "foo+test1@delighted.com")
```

Listing people who have unsubscribed (auto pagination not supported):

```ruby
# List all people who have unsubscribed, 20 per page, first 2 pages
survey_responses_page1 = Delighted::Unsubscribe.all
survey_responses_page2 = Delighted::Unsubscribe.all(:page => 2)
```

Listing people whose emails have bounced (auto pagination not supported):

```ruby
# List all people whose emails have bounced, 20 per page, first 2 pages
survey_responses_page1 = Delighted::Bounce.all
survey_responses_page2 = Delighted::Bounce.all(:page => 2)
```

Deleting a person and all of the data associated with them:

```ruby
# Delete by person id
Delighted::Person.delete(:id => 42)
# Delete by email address
Delighted::Person.delete(:email => "test@example.com")
# Delete by phone number (must be E.164 format)
Delighted::Person.delete(:phone_number => "+14155551212")
```

Deleting pending survey requests

```ruby
# Delete all pending (scheduled but unsent) survey requests for a person, by email.
Delighted::SurveyRequest.delete_pending(:person_email => "foo+test1@delighted.com")
```

Adding survey responses:

```ruby
# Add a survey response, score only
survey_response1 = Delighted::SurveyResponse.create(:person => person1.id,
  :score => 10)

# Add *another* survey response (for the same person), score and comment
survey_response2 = Delighted::SurveyResponse.create(:person => person1.id,
  :score => 5, :comment => "Really nice.")
```

Retrieving a survey response:

```ruby
# Retrieve an existing survey response
survey_response3 = Delighted::SurveyResponse.retrieve('123')
```

Updating survey responses:

```ruby
# Update a survey response score
survey_response4 = Delighted::SurveyResponse.retrieve('234')
survey_response4.score = 10
survey_response4.save #=> #<Delighted::SurveyResponse:...>

# Update (or add) survey response properties
survey_response4.person_properties = { :segment => "Online" }
survey_response4.save #=> #<Delighted::SurveyResponse:...>

# Update person who recorded the survey response
survey_response4.person = '321'
survey_response4.save #=> #<Delighted::SurveyResponse:...>
```

Listing survey responses:

```ruby
# List all survey responses, 20 per page, first 2 pages
survey_responses_page1 = Delighted::SurveyResponse.all
survey_responses_page2 = Delighted::SurveyResponse.all(:page => 2)

# List all survey responses, 20 per page, expanding person object
survey_responses_page1_expanded = Delighted::SurveyResponse.all(:expand => ['person'])
survey_responses_page1_expanded[0].person #=> #<Delighted::Person:...>

# List all survey responses, 20 per page, for a specific trend (ID: 123)
survey_responses_page1_trend = Delighted::SurveyResponse.all(:trend => "123")

# List all survey responses, 20 per page, in reverse chronological order (newest first)
survey_responses_page1_desc = Delighted::SurveyResponse.all(:order => 'desc')

# List all survey responses, 100 per page, page 5, with a time range
filtered_survey_responses = Delighted::SurveyResponse.all(:page => 5,
  :per_page => 100, :since => Time.utc(2013, 10, 01),
  :until => Time.utc(2013, 11, 01))
```

Getting Autopilot state:

```ruby
email_autopilot_state = Delighted::AutopilotConfiguration.retrieve("email")
sms_autopilot_state = Delighted::AutopilotConfiguration.retrieve("sms")
```

Listing Autopilot members:

```ruby
email_autopilot_members = Delighted::AutopilotMembership::Email.list
begin
  email_autopilot_members.auto_paging_each do |membership|
    # Do something with membership
  end
rescue Delighted::RateLimitError => e
  # Indicates how long to wait before making this request again
  e.retry_after
  retry
end

# For convenience, this method can use a sleep to automatically handle rate limits
email_autopilot_members.auto_paging_each({ auto_handle_rate_limits: true }) do |membership|
  # Do something with membership
end
```

Look up specific Autopilot member:

```ruby
Delighted::AutopilotMembership::Email
  .list(person_email: "foo+test1@delighted.com") # or person_id or person_phone_number
  .auto_paging_each({ auto_handle_rate_limits: true }) do |membership|
    # Do something with membership. If no membership for this person exists, 
    # this block will never be called.
end
```

Add a person to Autopilot:

```ruby
props = {
  "Shoe Type" => "Sneaker",
  "Handedness" => "Left"
}
result = Delighted::AutopilotMembership::Email.create(
  person_email: "foo+test1@delighted.com", 
  properties: props
)
```

Update a person in Autopilot:

```ruby
props = {
  "Shoe Type" => "Sandal",
  "Handedness" => "Left"
}
result = Delighted::AutopilotMembership::Email.create(
  person_email: "foo+test1@delighted.com", 
  properties: props
)
```

Remove a person from Autopilot:

```ruby
result = Delighted::AutopilotMembership::Sms.delete(
  person_phone_number: "+15555551212"
)

result = Delighted::AutopilotMembership::Sms.delete(person_id: "433523")
```

Retrieving metrics:

```ruby
# Get current metrics, 30-day simple moving average, from most recent response
metrics = Delighted::Metrics.retrieve

# Get current metrics, 30-day simple moving average, from most recent response,
# for a specific trend (ID: 123)
metrics = Delighted::Metrics.retrieve(:trend => "123")

# Get metrics, for given range
metrics = Delighted::Metrics.retrieve(:since => Time.utc(2013, 10, 01),
  :until => Time.utc(2013, 11, 01))
```

## Rate limits

If a request is rate limited, a `Delighted::RateLimitedError` exception is raised. You can rescue that exception to implement exponential backoff or retry strategies. The exception provides a `#retry_after` method to tell you how many seconds you should wait before retrying. For example:

```ruby
begin
  metrics = Delighted::Metrics.retrieve
rescue Delighted::RateLimitedError => e
  retry_after_seconds = e.retry_after
  # wait for retry_after_seconds before retrying
  # add your retry strategy here ...
end
```

## <a name="advanced-configuration"></a> Advanced configuration & testing

The following options are configurable for the client:

```ruby
Delighted.api_key
Delighted.api_base_url # default: 'https://api.delighted.com/v1'
Delighted.http_adapter # default: Delighted::HTTPAdapter.new
```

By default, a shared instance of `Delighted::Client` is created lazily in `Delighted.shared_client`. If you want to create your own client, perhaps for test or if you have multiple API keys, you can:

```ruby
# Create a custom client instance, and pass as last argument to resource actions
client = Delighted::Client.new(:api_key => 'API_KEY',
  :api_base_url => 'https://api.delighted.com/v1',
  :http_adapter => Delighted::HTTPAdapter.new)
metrics_from_custom_client = Delighted::Metrics.retrieve({}, client)

# Or, you can set Delighted.shared_client yourself
Delighted.shared_client = Delighted::Client.new(:api_key => 'API_KEY',
  :api_base_url => 'https://api.delighted.com/v1',
  :http_adapter => Delighted::HTTPAdapter.new)
metrics_from_custom_shared_client = Delighted::Metrics.retrieve
```

## Supported runtimes

- Ruby MRI (1.8.7+)
- JRuby (1.8 + 1.9 modes)
- REE (1.8.7-2012.02)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the tests (`rake test`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## Releasing

1. Bump the version in `lib/delighted/version.rb`.
2. Update the README and CHANGELOG as needed.
3. Tag the commit for release.
4. Build the gem with `gem build delighted.gemspec`.
5. Install locally to verify `gem install PATH_TO_GENERATED_GEM.gem`.
6. Push to Rubygems.org with `gem push PATH_TO_GENERATED_GEM.gem`.
