module Delighted
  module Operations
    module Retrieve
      def self.included(klass)
        if klass.singleton_resource?
          klass.extend(Singleton::ClassMethods)
        else
          klass.extend(Pluralton::ClassMethods)
        end
      end

      module Pluralton
        module ClassMethods
          def retrieve(id, client = Delighted.shared_client)
            json = client.get_json(path(id))
            new(json)
          end

          def path(id = nil)
            id ? "#{@path}/#{id}" : @path
          end
        end
      end

      module Singleton
        module ClassMethods
          def retrieve(opts = {}, client = Delighted.shared_client)
            json = client.get_json(path, opts)
            new(json)
          end
        end
      end
    end
  end
end
