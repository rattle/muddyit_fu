class Muddyit::Sites::Site::Pages::Page < Muddyit::Generic

  # Create a set of entities from the categorisation results
  def initialize(muddyit, attributes = {})
    super(muddyit, attributes)
    create_entities
    @extracted_content_cache = nil
  end

  # submit a page or text for re-categorisation
  #
  # Params
  # * options (Required)
  #
  def update(options = {})

    # Ensure we get extracted_content as well
    options[:include_content] = true

    body = { :page => { :uri => self.uri, :options => options } }

    api_url = "/sites/#{self.site.attributes[:token]}/pages/#{self.identifier}"
    response = @muddyit.send_request(api_url, :put, {}, body.to_json)
    return Muddyit::Sites::Site::Pages::Page.new(@muddyit, response['page'].merge!(:site => self.site))
  end


  # get extracted_content for page
  #
  def extracted_content
    if @extracted_content_cache.nil?
      if @attributes[:extracted_content]
        @extracted_content_cache = Muddyit::Sites::Site::Pages::Page::ExtractedContent.new(@muddyit, @attributes[:extracted_content])
      else
        r = self.fetch
        @extracted_content_cache = Muddyit::Sites::Site::Pages::Page::ExtractedContent.new(@muddyit, r[:extracted_content])
      end
    end
    @extracted_content_cache
  end

  
  # delete the page
  #
  def destroy
    api_url = "/sites/#{self.site.attributes[:token]}/pages/#{@attributes[:identifier]}"
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
    api_url = "/sites/#{self.site.attributes[:token]}/pages/#{@attributes[:identifier]}/related"
    response = @muddyit.send_request(api_url, :get, options, nil)
    results = []
    response.each { |result|
      # The return format needs sorting out here .......
      results.push :page => @attributes[:site].pages.find(result['identifier']), :count => result['count']
    }
    return results
  end

  protected
  def fetch
    api_url = "/sites/#{self.site.attributes[:token]}/pages/#{@attributes[:identifier]}"
    
    response = @muddyit.send_request(api_url, :get, {:include_content => true}, nil)

    response.nested_symbolize_keys!
  end

  # Convert results to entities
  def create_entities
    results = []
    if @attributes.has_key?(:entities)
      @attributes[:entities].each do |result|
         results.push Muddyit::Sites::Site::Entities::Entity.new(@muddyit, result.merge!(:site => @attributes[:site]))
      end
      @attributes[:entities] = results
    end
  end

end