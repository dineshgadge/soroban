require 'soroban/helpers'
require 'soroban/functions'
require 'soroban/walker'
require 'soroban/cell'

module Soroban

  class Sheet
    attr_reader :cells, :bindings

    def initialize
      @cells = []
      @bindings = {}
    end

    def method_missing(method, *args, &block)
      if match = /^func_(.*)$/i.match(method.to_s)
        return Soroban::call(self, match[1], *args)
      elsif match = /^([a-z][\w]*)=$/i.match(method.to_s)
        return _add(match[1], args[0])
      end
      super
    end

    def set(label_or_range, contents)
      _add(label_or_range, contents)
    end

    def get(label_or_name)
      eval("@#{label_or_name}.get", binding)
    end

    def bind(name, label)
      unless @cells.include?(label.to_sym)
        raise Soroban::ReferenceError, "Cannot bind '#{name}' to non-existent cell '#{label}'"
      end
      _bind(name, label)
    end

    def walk(range)
      Walker.new(range, binding)
    end

    def missing
      []
    end

  private

    def _add(label_or_range, contents)
      label = label_or_range
      @cells << label.to_sym
      internal = "@#{label}"
      _expose(internal, label)
      instance_variable_set(internal, Cell.new(contents, binding))
    end

    def _bind(name, label)
      @bindings[name.to_sym] = label.to_sym
      internal = "@#{label}"
      _expose(internal, name)
    end

    def _expose(internal, name)
      instance_eval <<-EOV, __FILE__, __LINE__ + 1
        def #{name}
          #{internal}.get
        end
        def #{name}=(contents)
          #{internal}.set(contents)
        end
      EOV
    end

  end

end