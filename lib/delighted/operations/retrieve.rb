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
          def retrieve(id, opts = {}, client = Delighted.shared_client)
            opts = Utils.serialize_values(opts)
            json = client.get_json(path(id), opts)
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
            opts = Utils.serialize_values(opts)
            json = client.get_json(path, opts)
            new(json)
          end
        end
      end
    end
  end
end
