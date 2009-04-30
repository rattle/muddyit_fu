class Muddyit::Sites::Site::Pages < Muddyit::Generic

  # find a specific page from the site
  #
  # Params
  # * type (Required)
  #     one of :all or a page identifier
  #
  def find(type, options = {})
    raise 'no type specified' if type.nil?

    if type.is_a? Symbol
      case type
      when :all
        api_url = "#{@muddyit.rest_endpoint}/sites/#{self.site.attributes[:token]}/pages"
        if block_given?
          token = nil
          begin
          response = @muddyit.send_request(api_url, :get, options.merge!(:page => token))
          response['resultsets'].each { |page|
            yield Muddyit::Sites::Site::Page.new(@muddyit, page.merge!(:site => self.site))
          }
          token = response['next_page']
          # Need to figure out which of the below actually occurs
          end while !token.nil? || !token == ''
        else
          api_url = "#{@muddyit.rest_endpoint}/sites/#{self.site.attributes[:token]}/pages"
          response = @muddyit.send_request(api_url, :get, options)

          pages = []
          response['resultsets'].each { |page| pages.push Muddyit::Sites::Site::Page.new(@muddyit, page.merge!(:site => self.site)) }
          return { :next_page => response['next_page'], :pages => pages }
        end
      else
        raise 'invalid type specified'
      end

    elsif type.is_a? String
      api_url = "#{@muddyit.rest_endpoint}/sites/#{self.site.attributes[:token]}/pages/#{URI.escape(CGI.escape(type),'.')}"
      response = @muddyit.send_request(api_url, :get, {})
      response.has_key?('results') ? Muddyit::Sites::Site::Page.new(@muddyit, response.merge!(:site => self.site)) : nil
    end
  end

  # retrieve entities related to this page
  #
  # Params
  # * options (Optional)
  #
  def related_entities(uri, options = {})
    raise "no uri supplied" if uri.nil?
    api_url = "#{@muddyit.rest_endpoint}/sites/#{self.site.attributes[:token]}/pages/related/entities/#{URI.escape(CGI.escape(uri),'.')}"
    response = @muddyit.send_request(api_url, :get, options)

    results = []
    response.each { |result|
      # The return format needs sorting out here .......
      results.push Muddyit::Entity.new(@muddyit, result)
    }
    return results
  end

  # submit a page or text for categorisation
  #
  # Params
  # * options (Required)
  #
  def categorise(options)

    # Ensure we get content_data as well
    options[:include_content] = true

    # Set the URI if not set
    options[:uri] = options[:identifier] if options.has_key?(:identifier) && !options.has_key?(:uri) && !options.has_key?(:text)

    # Ensure we have encoded the identifier and URI
    if options.has_key?(:uri)
      raise if options[:uri].nil?
      options[:uri] = URI.escape(CGI.escape(options[:uri]),'.')
    elsif options.has_key?(:identifier)
      raise if options[:identifier].nil?
      options[:identifier] = URI.escape(CGI.escape(options[:identifier]),'.')
    end

    api_url = "#{@muddyit.rest_endpoint}/sites/#{self.site.attributes[:token]}/pages/categorise"
    response = @muddyit.send_request(api_url, :post, options)
    return Muddyit::Sites::Site::Page.new(@muddyit, response.merge!(:site => self.site))
  end

  # find all pages with specified entity
  #
  # Params
  # * uri (Required)
  #   a dbpedia URI
  # * options (Optional)
  #
  #
  def find_by_entity(uri, options = {}, &block)
    queryAllWithURI(uri, options, &block)
  end

  # find all pages with specified entities
  #
  # Params
  # * uris (Required)
  #   an array of dbpedia URIs
  # * options (Optional)
  #
  #
  def find_by_entities(uris, options = {}, &block)
    queryAllWithURI(uris.join(','), options, &block)
  end

  # find all pages with specified term
  #
  # Params
  # * term (Required)
  #   a string e.g. 'Gordon Brown'
  # * options (Optional)
  #
  #
  def find_by_term(term, options = {}, &block)
    queryAllWithTerm(term, options, &block)
  end

  # find all pages with specified terms
  #
  # Params
  # * terms (Required)
  #   an array of strings e.g. ['Gordon Brown', 'Tony Blair']
  # * options (Optional)
  #
  #
  def find_by_terms(terms, options = {}, &block)
    queryAllWithTerm(terms.join(','), options, &block)
  end

  protected

  # find all pages with specified entit(y|ies)
  #
  # multiple uris may be specified using commas
  #
  # Params
  # * options (Required)
  #     must contain uri parameter which corresponds to dbpedia uri
  #
  def queryAllWithURI(uri, options, &block)
    api_url = "#{@muddyit.rest_endpoint}/sites/#{self.site.attributes[:token]}/pages/withentities/#{URI.escape(CGI.escape(uri),'.')}"
    query_page(api_url, options, &block)
  end

  # find all pages with specified term(s)
  #
  # multiple terms may be specified using commas
  #
  # Params
  # * options (Required)
  #
  #
  def queryAllWithTerm(term, options, &block)
    api_url = "#{@muddyit.rest_endpoint}/sites/#{self.site.attributes[:token]}/pages/withterms/#{URI.escape(CGI.escape(term),'.')}"
    query_page(api_url, options, &block)
  end

  # utility method for term and uri query calls
  #
  # Params
  # * api_url (Required)
  #     must contain uri to make request to
  #
  def query_page(api_url, options)
    if block_given?
      token = nil
      begin
        options.merge!(:page => token) unless token.nil?
        response = @muddyit.send_request(api_url, :get, options)
        response['resultsets'].each { |page|
          yield Muddyit::Sites::Site::Page.new(@muddyit, page.merge!(:site => self.site))
        }
        token = response['next_page']
        # Need to figure out which of the below actually occurs
      end while !token.nil? || !token == ''
    else
      response = @muddyit.send_request(api_url, :get, {})

      pages = []
      response['resultsets'].each { |page| pages.push Muddyit::Sites::Site::Page.new(@muddyit, page.merge!(:site => self.site)) }
      return { :next_page => response[:next_page], :pages => pages }
    end    
  end

end