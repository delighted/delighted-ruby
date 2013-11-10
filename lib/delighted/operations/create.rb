module Delighted
  module Operations
    module Create
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def create(attributes = {}, client = Delighted.shared_client)
          params = Utils.hash_without_key(attributes, :id)
          params = Utils.serialize_values(params)
          json = client.post_json(path, params)
          new(json)
        end
      end
    end
  end
end
