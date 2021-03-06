require 'rubygems'
require 'net/http'
require 'cgi'
require 'json'
#require 'json/ext'
#gem 'monkeyhelper-oauth', :lib => 'lib/oauth'
require 'oauth/consumer'
require 'digest/md5'
require 'forwardable'

require 'pp'


# Fix for broken oauth gem
module OAuth
  VERSION = "0.4.2"
end

# Fix for broken oauth gem
class String
  
  # these are to backport methods from 1.8.7/1.9.1 to 1.8.6
  
  unless method_defined?(:bytesize)
    def bytesize
      self.size
    end
  end
  
  unless method_defined?(:bytes)
    def bytes
      require 'enumerator'
      Enumerable::Enumerator.new(self, :each_byte)
    end
  end
  
end

class Module
  def class_attr_accessor(attribute_name)
    class_eval <<-CODE
      def self.#{attribute_name}
        @@#{attribute_name} ||= nil
      end
      def self.#{attribute_name}=(value)
        @@#{attribute_name} = value
      end
    CODE
  end
end


class Hash
  # File merb/core_ext/hash.rb, line 166
  def nested_symbolize_keys!
    each do |k,v|
      sym = k.respond_to?(:to_sym) ? k.to_sym : k
      self[sym] = Hash === v ? v.nested_symbolize_keys! : v
      delete(k) unless k == sym
    end
    self
  end

  def nested_stringify_keys!
    each do |k,v|
      s = k.respond_to?(:to_s) ? k.to_s : k
      self[s] = Hash === v ? v.nested_stringify_keys! : v
      delete(k) unless k == s
    end
    self
  end
  
end

# base must load first
%w(base oauth errors generic collections entities collections/collection collections/pages collections/pages/page collections/pages/page/extracted_content collections/entities collections/entities/entity).each do |file|
  require File.join(File.dirname(__FILE__), 'muddyit', file)
end
