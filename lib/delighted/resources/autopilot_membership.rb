module Delighted
  class AutopilotMembership < Resource
    # This is a class purely so that Sms and Email share a common semantic base class

    class << self
      def delete(person_id_hash, client = Delighted.shared_client)
        json = client.delete_json(path, person_id_hash)
        json.merge(:person => Person.new(json[:person]))
      end
    end

    class Sms < AutopilotMembership
      self.path = "/autopilot/sms/memberships"
      self.expandable_attributes = { :person => Person, :next_survey_request => SurveyRequest }

      include Operations::List
      include Operations::Create
    end

    class Email < AutopilotMembership
      self.path = "/autopilot/email/memberships"
      self.expandable_attributes = { :person => Person, :next_survey_request => SurveyRequest }

      include Operations::List
      include Operations::Create
    end
  end
end
