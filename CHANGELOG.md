## 2.0.0rc1 (Unreleased)

Features:

- Add `Delighted::Person.list`

Compatibility changes:

- Add support for Ruby 2.7
- Drop support for Ruby 1.8.7, 1.9.2, and ree

## 1.8.0 (2018-05-22)

Features:

- Add `Delighted::Person.delete`

## 1.7.0 (2017-10-18)

Features:

- Add `Delighted::RateLimitedError#retry_after`.
- Add `Delighted::Error#response`.

## 1.6.0 (2017-09-27)

Features:

- Add support for rate limited responses (`Delighted::RateLimitedError`)

## 1.5.1 (2015-10-06)

Fixes:

- Fixed tests that were failing in Ruby 1.8.7 (no changes to library code itself)

## 1.5.0 (2015-09-29)

Features:

- Add support for listing People who have unsubscribed
- Add support for listing People whose emails bounced

## 1.4.0 (Unreleased)

Features:

- Add support for retrieving a SurveyResponse
- Add support for updating a SurveyResponse

## 1.3.1 (2015-09-14)

Features:

- Fix authentication header on 1.8.7

## 1.3.0 (2014-06-03)

Features:

- Add support expanding person on SurveyResponses
- Add support for new Unsubscribes endpoint

## 1.2.0 (2014-02-28)

Features:

- Add test and usage details for specifying sort when listing SurveyResponses

## 1.1.0 (2014-01-12)

Features:

- Add support for canceling pending survey requests

## 1.0.0 (2013-12-13)
