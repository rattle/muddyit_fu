class Muddyit::Sites::Site::Page < Muddyit::Generic

  # Create a set of entities from the categorisation results
  def initialize(muddyit, attributes = {})
    super(muddyit, attributes)
    create_entities
    @content_data_cache = nil
  end

  # submit a page or text for re-categorisation
  #
  # Params
  # * options (Required)
  #
  def refresh(options = {})

    # Ensure we get content_data as well
    options[:include_content] = true

    body = { :page => { :uri => self.uri }, :options => options }

    api_url = "/sites/#{self.site.attributes[:token]}/pages/#{URI.escape(CGI.escape(self.identifier),'.')}"
    response = @muddyit.send_request(api_url, :put, {}, body.to_json)
    return Muddyit::Sites::Site::Page.new(@muddyit, response.merge!(:site => self.site))
  end


  # get content_data for page
  #
  def content_data
    if @content_data_cache.nil?
      if @attributes[:content_data]
        @content_data_cache = Muddyit::Sites::Site::Page::ContentData.new(@muddyit, @attributes[:content_data])
      else
        r = self.fetch
        @content_data_cache = Muddyit::Sites::Site::Page::ContentData.new(@muddyit, r[:content_data])
      end
    end
    @content_data_cache
  end

  
  # delete the page
  #
  def destroy
    api_url = "/sites/#{self.site.attributes[:token]}/pages/#{URI.escape(CGI.escape(@attributes[:identifier]),'.')}"
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
    api_url = "/sites/#{self.site.attributes[:token]}/pages/#{URI.escape(CGI.escape(@attributes[:identifier]),'.')}/related/content"
    response = @muddyit.send_request(api_url, :get, options)
    results = []
    response.each { |result|
      # The return format needs sorting out here .......
      results.push :page => @attributes[:site].pages.find(result['identifier']), :count => result['count']
    }
    return results
  end

  protected
  def fetch
    api_url = "/sites/#{self.site.attributes[:token]}/pages/#{URI.escape(CGI.escape(@attributes[:identifier]),'.')}"
    response = @muddyit.send_request(api_url, :get, {:include_content => true })
    response.nested_symbolize_keys!
  end

  # Convert results to entities
  def create_entities
    results = []
    if @attributes.has_key?(:entities)
      @attributes[:entities].each do |result|
         results.push Muddyit::Entity.new(@muddyit, result)
      end
      @attributes[:entities] = results
    end
  end

end