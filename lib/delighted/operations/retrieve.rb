module Delighted
  module Operations
    module Retrieve
      def self.included(klass)
        if klass.singleton_resource?
          Operations.add_operations(klass, Singleton::OperationClassMethods)
        else
          klass.extend(Pluralton::AuxiliaryClassMethods)
          Operations.add_operations(klass, Pluralton::OperationClassMethods)
        end
      end

      module Pluralton
        module OperationClassMethods
          def retrieve(client, id)
            json = client.get_json(path(id))
            new(json)
          end
        end

        module AuxiliaryClassMethods
          def path(id = nil)
            id ? "#{@path}/#{id}" : @path
          end
        end
      end

      module Singleton
        module OperationClassMethods
          def retrieve(client, opts = {})
            json = client.get_json(path, opts)
            new(json)
          end
        end
      end
    end
  end
end
