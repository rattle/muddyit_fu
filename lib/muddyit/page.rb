class Muddyit::Sites::Site::Page < Muddyit::Generic

  # Create a set of entities from the categorisation results
  def initialize(muddyit, attributes = {})
    super(muddyit, attributes)
    create_entities
  end

  # submit a page or text for re-categorisation
  #
  # Params
  # * options (Required)
  #
  def refresh(options)

    # Ensure we get content_data as well
    options[:include_content] = true unless options.has_key?(:include_content)

    # Set the URI if not set
    options[:uri] = options[:identifier] if options.has_key?(:identifier) && !options.has_key?(:uri) && !options.has_key?(:text)

    # Ensure we have encoded the identifier and URI
    if options.has_key?(:uri)
      options[:uri] = URI.escape(CGI.escape(options[:uri]),'.')
    elsif options.has_key?(:identifier)
      options[:identifier] = URI.escape(CGI.escape(options[:identifier]),'.')
    end

    api_url = "#{@muddyit.rest_endpoint}/sites/#{self.site.attributes[:token]}/pages/#{URI.escape(CGI.escape(@attributes[:identifier]),'.')}/refresh"
    response = @muddyit.send_request(api_url, :post, options)
    return Muddyit::Sites::Site::Page.new(@muddyit, response.merge!(:site => self.site))
  end


  # get content_data for page
  #
  def content_data
    Muddyit::Sites::Site::Page::ContentData.new(@muddyit, @attributes[:content_data])
  end

  # delete the page
  #
  def destroy
    api_url = "#{@muddyit.rest_endpoint}/sites/#{self.site.attributes[:token]}/pages/#{URI.escape(CGI.escape(@attributes[:identifier]),'.')}"
    response = @muddyit.send_request(api_url, :delete, {})
    # Is this the correct thing to return ?
    return true
  end

  # retrieve related pages
  #
  # Params
  # * options (Optional)
  #
  def related_content(options = {})
    api_url = "#{@muddyit.rest_endpoint}/sites/#{self.site.attributes[:token]}/pages/#{URI.escape(CGI.escape(@attributes[:identifier]),'.')}/related/content"
    response = @muddyit.send_request(api_url, :get, options)
    
    results = []
    response.each_key { |result|
      # The return format needs sorting out here .......
      results.push :page => @attributes[:site].pages.find(result.to_s), :count => response[result]['count']
    }
    return results
  end

  protected
  def fetch
    api_url = "#{@muddyit.rest_endpoint}/sites/#{self.site.attributes[:token]}/pages/#{URI.escape(CGI.escape(@attributes[:identifier]),'.')}"
    response = @muddyit.send_request(api_url, :get, {:include_content => true })
    response.nested_symbolize_keys!
  end

  # Convert results to entities
  def create_entities
    results = []
    if @attributes.has_key?(:results)
      @attributes[:results].each do |result|
         results.push Muddyit::Entity.new(@muddyit, result)
      end
      @attributes[:results] = results
    end
  end

end