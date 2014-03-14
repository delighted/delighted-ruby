module Delighted
  class SurveyResponse < Resource
    self.path = "/survey_responses"

    include Operations::Create
    include Operations::All

    def to_hash
      if Person === attributes[:person]
        Utils.hash_without_key(attributes, :person)
      else
        attributes
      end
    end

    protected

    def build_from_attributes(attributes)
      attributes_dup = attributes.dup

      if Hash === attributes_dup[:person]
        attributes_dup[:person] = Person.new(attributes_dup.delete(:person))
      end

      super(attributes_dup)
    end
  end
end
