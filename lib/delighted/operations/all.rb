module Delighted
  module Operations
    module All
      def self.included(klass)
        klass.extend(AuxiliaryClassMethods)
        Operations.add_operations(klass, OperationClassMethods)
      end

      module OperationClassMethods
        def all(client, opts = {})
          json = client.get_json(path, opts)
          EnumerableResourceCollection.new(json.map { |attributes| new(attributes) })
        end
      end

      module AuxiliaryClassMethods
        # pagination, enumerable stuff etc.
      end
    end
  end
end
