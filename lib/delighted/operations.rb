module Delighted
  module Operations
    def self.add_operations(klass, operation_module)
      klass.extend(operation_module)
      operation_module.instance_methods.each { |operation| klass.operations << operation }
    end
  end
end
