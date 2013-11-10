module Delighted
  module Operations
    module All
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def all(opts = {}, client = Delighted.shared_client)
          json = client.get_json(path, opts)
          EnumerableResourceCollection.new(json.map { |attributes| new(attributes) })
        end
      end
    end
  end
end
