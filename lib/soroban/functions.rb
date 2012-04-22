module Soroban

  def self.define(function_hash)
    @@functions ||= {}
    function_hash.each { |name, callback| @@functions[name] = callback }
  end 

  def self.functions
    @@functions.keys.map { |f| f.to_s }
  end

  def self.call(sheet, name, *args)
    function = name.upcase.to_sym
    raise Soroban::UndefinedError, "No such function '#{function}'" unless @@functions[function]
    sheet.instance_exec(*args, &@@functions[function])
  end

end

require 'soroban/functions/if'
require 'soroban/functions/sum'
require 'soroban/functions/vlookup'