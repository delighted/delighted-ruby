module Delighted
  class Resource
    class << self
      attr_accessor :path
      attr_writer :singleton_resource, :expandable_attributes

      def expandable_attributes
        @expandable_attributes ||= {}
      end

      def singleton_resource?
        !!@singleton_resource
      end

      def identifier_string(identifier_hash)
        raise ArgumentError, "must pass Hash" unless Hash === identifier_hash
        raise ArgumentError, "must pass exactly one identifier name and value" unless identifier_hash.size == 1

        identifier_key = identifier_hash.keys.first
        identifier_value = identifier_hash.values.first

        if identifier_key.to_s == "id"
          identifier_value.to_s
        else
          "#{identifier_key}:#{identifier_value}"
        end
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

    # Attributes used for serialization
    def to_hash
      serialized_attributes = attributes.dup

      self.class.expandable_attributes.each_pair.select do |attribute_name, expanded_class|
        if expanded_class === attributes[attribute_name]
          serialized_attributes[attribute_name] = serialized_attributes[attribute_name].id
        end
      end

      serialized_attributes
    end
    alias_method :to_h, :to_hash

    private

    def expanded_attribute_names
      names = Set.new

      self.class.expandable_attributes.each_pair.select do |attribute_name, expanded_class|
        if expanded_class === attributes[attribute_name]
          names << attribute_name
        end
      end

      names
    end

    def build_from_attributes(attributes)
      @attributes = Utils.hash_without_key(attributes, :id)

      self.class.expandable_attributes.each_pair do |attribute_name, expanded_class|
        if Hash === @attributes[attribute_name]
          @attributes[attribute_name] = expanded_class.new(@attributes.delete(attribute_name))
        end
      end

      define_attribute_accessors(@attributes.keys)
    end

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
