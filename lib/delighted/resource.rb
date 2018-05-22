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

      def identifier_string(id_hash)
        raise ArgumentError, "must pass Hash" unless Hash === id_hash

        id_key = id_hash.keys.detect { |k| !id_hash[k].to_s.empty? }
        raise ArgumentError, "must pass an identifier name and value" unless id_key
        id_value = id_hash[id_key]

        if id_key.to_s == "id"
          id_value.to_s
        else
          "#{id_key}:#{id_value}"
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
