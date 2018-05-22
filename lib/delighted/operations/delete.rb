module Delighted
  module Operations
    module Delete
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def path(id = nil)
          id ? "#{@path}/#{CGI.escape(id)}" : @path
        end

        def delete(id_hash, client = Delighted.shared_client)
          id = identifier_string(id_hash)
          client.delete_json(path(id))
        end
      end
    end
  end
end
