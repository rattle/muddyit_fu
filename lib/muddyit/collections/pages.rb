class Muddyit::Collections::Collection::Pages < Muddyit::Generic

  # find a specific page from the collection
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
        api_url = "/collections/#{self.collection.attributes[:token]}/pages"
        if block_given?
          token = nil
          begin
          response = @muddyit.send_request(api_url, :get, options.merge!(:page => token))
          response['pages'].each { |page|
            yield Muddyit::Collections::Collection::Pages::Page.new(@muddyit, page.merge!(:collection => self.collection))
          }
          token = response['next_page']
          # Need to figure out which of the below actually occurs
          end while !token.nil? || !token == ''
        else
          api_url = "/collections/#{self.collection.attributes[:token]}/pages"
          response = @muddyit.send_request(api_url, :get, options)

          pages = []
          response['pages'].each { |page| pages.push Muddyit::Collections::Collection::Pages::Page.new(@muddyit, page.merge!(:collection => self.collection)) }
          return { :next_page => response['next_page'], :pages => pages }
        end
      else
        raise 'invalid type specified'
      end

    elsif type.is_a? String
      api_url = "/collections/#{self.collection.attributes[:token]}/pages/#{type}"
      response = @muddyit.send_request(api_url, :get, {})
      response.has_key?('identifier') ? Muddyit::Collections::Collection::Pages::Page.new(@muddyit, response.merge!(:collection => self.collection)) : nil
    end
  end



  # submit a page or text for categorisation
  #
  # Params
  # * options (Required)
  #
  def create(doc, options = {})

    document = {}
    if doc.is_a? Hash
      unless doc[:uri] || doc[:text]
        raise
      end
      document = doc
    elsif doc.is_a? String
      if doc =~ /^http:\/\//
        document[:uri] = doc
      else
        document[:text] = doc
      end
    end

    # Ensure we get content_data as well
    options[:include_content] = true

    body = { :page => document.merge!(:options => options) }
    api_url = "/collections/#{self.collection.attributes[:token]}/pages/"
    response = @muddyit.send_request(api_url, :post, {}, body.to_json)
    return Muddyit::Collections::Collection::Pages::Page.new(@muddyit, response['page'].merge!(:collection => self.collection))
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
    api_url = "/collections/#{self.collection.attributes[:token]}/entities/#{Digest::MD5.hexdigest(uri)}"
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
    api_url = "/collections/#{self.collection.attributes[:token]}/terms/#{term}"
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
        response = @muddyit.send_request(api_url, :get, options.merge!(:page => token))
        response['pages'].each { |page|
          yield Muddyit::Collections::Collection::Pages::Page.new(@muddyit, page.merge!(:collection => self.collection))
        }
        token = response['next_page']
        # Need to figure out which of the below actually occurs
      end while !token.nil? || !token == ''
    else
      response = @muddyit.send_request(api_url, :get, {})

      pages = []
      response['pages'].each { |page| pages.push Muddyit::Collections::Collection::Pages::Page.new(@muddyit, page.merge!(:collection => self.collection)) }
      return { :next_page => response[:next_page], :pages => pages }
    end    
  end

end