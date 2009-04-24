class Muddyit::Sites < Muddyit::Base

  # create a new sites object
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

  # find a specific site
  #
  # Params
  # * type (Required)
  #   one of :all or a site token
  #
  def find(type, options = {})
    raise 'no type specified' unless type

    if type.is_a? Symbol
      case type
      when :all
        api_url = "#{@muddyit.rest_endpoint}/sites/"
        response = @muddyit.send_request(api_url, :get, options)
        sites = []
        response.each { |site| sites.push Muddyit::Sites::Site.new(@muddyit, site['site']) }
        return sites
      else
        raise 'invalid type specified'
      end
    elsif type.is_a? String
      api_url = "#{@muddyit.rest_endpoint}/sites/#{type}"
      response = @muddyit.send_request(api_url, :get, options)
      return Muddyit::Sites::Site.new(@muddyit, response['site'])
    else
      raise 'invalid type specified'
    end

  end

end