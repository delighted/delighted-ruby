module Delighted
  class SurveyRequest < Resource
    self.path = "/people/{PERSON_EMAIL}/survey_requests"

    def self.delete_pending(attributes = {}, client = Delighted.shared_client)
      interpolated_path = path.sub("{PERSON_EMAIL}", CGI.escape(attributes[:person_email]))
      interpolated_path << "/pending"
      json = client.delete_json(interpolated_path)
      json
    end
  end
end
