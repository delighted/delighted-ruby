require 'date'

module Delighted
  module Utils
    def self.eigenclass(object)
      class << object; self; end
    end

    def self.hash_without_key(hash, key)
      hash.reject { |k,v| k == key }.inject({}) { |memo,(k,v)| memo[k] = v; memo }
    end

    def self.to_query(hash_or_array, namespace = nil)
      hash_or_array.map { |object|
        k, v = case hash_or_array
        when Hash then object
        when Array then [nil, object]
        else raise ArgumentError, "must pass Hash or Array"
        end

        namespaced_k = namespace ? "#{namespace}[#{k}]" : k

        case v
        when Hash, Array then to_query(v, namespaced_k)
        else "#{CGI.escape(namespaced_k.to_s)}=#{CGI.escape(v.to_s)}"
        end
      }.join("&")
    end

    def self.symbolize_keys(object)
      case object
      when Hash
        object.inject({}) { |memo,(k,v)|
          memo[(k.to_sym rescue k)] = Hash === v ? symbolize_keys(v) : v
          memo
        }
      when Array
        object.map { |v| symbolize_keys(v) }
      else
        object
      end
    end

    def self.serialize_values(object)
      case object
      when Time, Date
        object.to_i
      when Hash
        object.inject({}) { |memo,(k,v)|
          memo[k] = serialize_values(v)
          memo
        }
      when Array, Set
        object.map { |v| serialize_values(v) }
      else
        object
      end
    end

    # From Rails.
    def self.wrap_array(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      else
        [object]
      end
    end

    def self.full_const_get(name)
      list = name.split("::")
      list.shift if list.first.nil? || list.first.empty?
      obj = Object
      list.each do |x|
        obj = obj.const_defined?(x) ? obj.const_get(x) : obj.const_missing(x)
      end
      obj
    end
  end
end

# Delighted::Utils.symbolize_keys([1, {'goo' => { 'bar' => 1, :gyp => ['x'] }, foo: Object.new }])
# URI.unescape Delighted::Utils.to_query(foo: 1, gyp: { sum: 1, welp: ['a','b'] })
