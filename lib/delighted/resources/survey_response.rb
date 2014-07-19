module Delighted
  class SurveyResponse < Resource
    self.path = "/survey_responses"
    self.expandable_attributes = { :person => Person }

    include Operations::Create
    include Operations::All
    include Operations::Update
    include Operations::Retrieve
  end
end
