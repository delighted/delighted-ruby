module Delighted
  class SurveyResponse < Resource
    self.path = "/survey_responses"

    include Operations::Create
    include Operations::All
  end
end
