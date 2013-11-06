module Delighted
  module Operations
    module Create
      def self.included(klass)
        Operations.add_operations(klass, OperationClassMethods)
      end

      module OperationClassMethods
        def create(client, attributes = {})
          params = Utils.hash_removing_key(attributes, :id)
          json = client.post_json(path, params)
          new(json)
        end
      end
    end
  end
end
