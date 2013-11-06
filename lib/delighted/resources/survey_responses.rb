module Delighted
  class SurveyResponse < Resource
    self.interface_name = "survey_responses"
    self.path = "/survey_responses"

    include Operations::Create
    include Operations::All
  end
end
