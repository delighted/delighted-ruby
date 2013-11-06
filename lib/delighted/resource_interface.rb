module Delighted
  class ResourceInterface
    def initialize(client, resource)
      @resource = resource # more helpful inspect

      Utils.eigenclass(self).instance_eval do
        resource.operations.each do |operation|
          define_method(operation) do |*args, &block|
            resource.send(operation, *args.unshift(client), &block)
          end
        end
      end
    end

    def to_s
      inspect
    end
  end
end
