class Muddyit::Collections < Muddyit::Base

  # create a new collections object
  # not a muddyit:generic as it doesn't need the method missing loader
  #
  # Params :
  #
  # * muddyit (Required)
  # a muddyit::base instance
  #
  def initialize(muddyit)
    @muddyit = muddyit
  end

  # find a specific collection
  #
  # Params
  # * type (Required)
  #   one of :all or a token
  #
  def find(type, options = {})
    raise 'no type specified' unless type

    if type.is_a? Symbol
      case type
      when :all
        api_url = "/collections/"
        response = @muddyit.send_request(api_url, :get, options)
        collections = []
        response.each { |collection| collections.push Muddyit::Collections::Collection.new(@muddyit, collection['collection']) }
        return collections
      else
        raise 'invalid type specified'
      end
    elsif type.is_a? String
      api_url = "/collections/#{type}"
      response = @muddyit.send_request(api_url, :get, options)
      return Muddyit::Collections::Collection.new(@muddyit, response['collection'])
    else
      raise 'invalid type specified'
    end

  end

end