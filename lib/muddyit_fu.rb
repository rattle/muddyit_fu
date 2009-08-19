require 'rubygems'
require 'net/http'
require 'cgi'
require 'json'
#require 'json/ext'
#gem 'monkeyhelper-oauth', :lib => 'lib/oauth'
require 'oauth/consumer'
require 'digest/md5'

require 'pp'

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
%w(base errors generic sites entities sites/site sites/pages sites/pages/page sites/pages/page/extracted_content sites/entities sites/entities/entity).each do |file|
  require File.join(File.dirname(__FILE__), 'muddyit', file)
end


