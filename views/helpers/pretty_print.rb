require "awesome_print"
require 'sinatra/base'

module Demo
  module PrettyPrint
    def pretty_print(object, level = 1)
      hashify(object, level).ai(html: true, indent: 2, plain: true)
    end

    def hashify(object, level = 1)
      return object if [Fixnum, Float, Symbol, BigDecimal, NilClass, TrueClass, FalseClass, Time].include?(object.class)
      return object.map{|item| hashify(item, level)} if object.is_a?(Array)
      return object.inject({}){|hash, (item, value)| hash[hashify(item)] = hashify(value); hash} if object.is_a?(Hash)
      return object[0..30]+"..." if object.is_a?(String) && object.length > 30
      return object if object.is_a?(String)

      return object.class if level.zero?
      return object.instance_variables.inject({}) do |hash, name|
        value = object.instance_variable_get(name.to_s)
        hash[name] = hashify(value, level-1);
        hash
      end
    end
  end
end
