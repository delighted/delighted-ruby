module Delighted
  class Resource
    class << self
      def path=(path)
        @path = path
      end

      def path
        @path
      end

      def singleton_resource=(singleton_resource)
        @singleton_resource = singleton_resource
      end

      def singleton_resource?
        !!@singleton_resource
      end
    end

    undef :id if method_defined?(:id)
    attr_reader :attributes
    private :attributes

    def initialize(attributes = {})
      @id = attributes[:id]
      define_id_reader if @id
      build_from_attributes(attributes)
    end

    def to_hash
      attributes
    end
    alias_method :to_h, :to_hash

    protected

    def build_from_attributes(attributes)
      @attributes = Utils.hash_without_key(attributes, :id)
      define_attribute_accessors(@attributes.keys)
    end

    private

    def define_id_reader
      Utils.eigenclass(self).instance_eval do
        attr_reader :id
      end
    end

    def define_attribute_accessors(keys)
      Utils.eigenclass(self).instance_eval do
        keys.each do |key|
          define_method(key) do
            attributes[key]
          end

          define_method("#{key}=") do |value|
            attributes[key] = value
          end
        end
      end
    end
  end
end
