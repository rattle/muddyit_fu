class Muddyit::Generic < Muddyit::Base

  # superclass for data objects to inherit
  #
  # allows us to change the api with little code change via the magic of method
  # missing :)
  #

  attr_accessor :attributes

  # constructor
  #
  # Params
  # * muddyit (Required)
  #     a muddyit::base object
  # * attributes (Optional)
  #     hash of method => value entries used to simulate methods on a real object
  #
  def initialize(muddyit, attributes = {})
    @muddyit = muddyit
    @attributes = attributes.nested_symbolize_keys!
    @info_added = false
  end

  # request data from muddy.it if we haven't done so before and we don't have 
  # the attribute requested (acts as getter + setter)
  #
  # Params
  # * method (Required)
  #     the object method to populate, from attributes or remotely
  # * args (Optional)
  #     the value to set the method to
  #
  def method_missing(method, args = nil)
    if @info_added == false and !@attributes.has_key?(method.to_sym)
      #puts "Searching for missing method #{method.to_s}"
      @attributes.merge!(self.fetch)
      @info_added = true
    end
    unless @attributes.has_key?(method.to_sym)
      puts "Failed to find missing method #{method.to_s}"
      raise
    end
    if args.nil?
      @attributes[method.to_sym]
    else
      @attributes[method.to_sym] = args
      return true
    end
  end

  protected

  # method used to retrieve data from muddy.it service, to be overridden
  #
  def fetch
    raise "not implemented"
  end

end