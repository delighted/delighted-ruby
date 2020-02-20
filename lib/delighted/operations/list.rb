module Delighted
  module Operations
    module List
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def list(opts = {}, client = Delighted.shared_client)
          ListResource.new(self.name, path, Utils.serialize_values(opts), client)
        end
      end
    end
  end
end
