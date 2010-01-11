module Muddyit

  def self.new(*params)
    Muddyit::Base.new(*params)
  end

  class Base
    class_attr_accessor :http_open_timeout
    class_attr_accessor :http_read_timeout
    attr_accessor :rest_endpoint
    attr_reader :consumer_key, :consumer_secret, :access_token, :access_token_secret, :username, :password, :auth_type

    @@http_open_timeout = 120
    @@http_read_timeout = 120

    REST_ENDPOINT = 'http://www.muddy.it'

    # Set the request signing method
    @@digest1   = OpenSSL::Digest::Digest.new("sha1")
    @@digest256 = nil
    if OpenSSL::OPENSSL_VERSION_NUMBER > 0x00908000
      @@digest256 = OpenSSL::Digest::Digest.new("sha256") rescue nil # Some installation may not support sha256
    end
    
    # create a new muddyit object
    #
    # You can either pass a hash with the following attributes:
    #
    # * :consumer_key (Required)
    #     the consumer key
    # * :consumer_secret (Required)
    #     the consumer secret
    # * :access_token (Required)
    #     the token
    # * :access_token_secret (Required)
    #     the token secret
    # * :rest_endpoint (Optional)
    #     the muddy.it rest service endpoint
    # or:
    # * config_file (Required)
    #     yaml file to load configuration from
    #
    # Config Example (yaml file)
    # ---
    # consumer_key: AAA
    # consumer_secret: BBB
    # access_token: CCC
    # access_token_secret: DDD
    #
    def initialize(config_hash_or_file)
      if config_hash_or_file.is_a? Hash
        config_hash_or_file.nested_symbolize_keys!
        @username = config_hash_or_file[:username]
        @password = config_hash_or_file[:password]
        @consumer_key = config_hash_or_file[:consumer_key]
        @consumer_secret = config_hash_or_file[:consumer_secret]
        @access_token = config_hash_or_file[:access_token]
        @access_token_secret = config_hash_or_file[:access_token_secret]
        @rest_endpoint = config_hash_or_file.has_key?(:rest_endpoint) ? config_hash_or_file[:rest_endpoint] : REST_ENDPOINT
      else
        config = YAML.load_file(config_hash_or_file)
        config.nested_symbolize_keys!
        @username = config[:username]
        @password = config[:password]
        @consumer_key = config[:consumer_key]
        @consumer_secret = config[:consumer_secret]
        @access_token = config[:access_token]
        @access_token_secret = config[:access_token_secret]
        @rest_endpoint = config.has_key?(:rest_endpoint) ? config[:rest_endpoint] : REST_ENDPOINT
      end

      if !@consumer_key.nil?
        @auth_type = :oauth
        @consumer = ::OAuth::Consumer.new(@consumer_key, @consumer_secret, {:site=>@rest_endpoint})
        @accesstoken = ::OAuth::AccessToken.new(@consumer, @access_token, @access_token_secret)
      elsif !@username.nil?
        @auth_type = :basic
      else
        raise "unable to find authentication credentials"
      end

    end

    # sends a request to the muddyit REST api
    #
    # Params
    # * api_url (Required)
    #     the request url (uri.path)
    # * http_method (Optional)
    #     choose between GET (default), POST, PUT, DELETE http request.
    # * options (Optional)
    #     hash of query parameters, you do not need to include access_key_id, secret_access_key because these are added automatically
    #
    def send_request(api_url, http_method = :get, opts = {}, body = nil)

      raise 'no api_url supplied' unless api_url
      
      res = nil
      case @auth_type
      when :oauth
        res = oauth_request_over_http(api_url, http_method, opts, body)
      when :basic
        res = basic_request_over_http(api_url, http_method, opts, body)
      end

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        case res.body
        when " "
          return res
        when /^.+\((.+)\)$/
          # Strip any js callback method
          return JSON.parse($1)
        else
          return JSON.parse(res.body)
        end
      when Net::HTTPNotFound
        return res
      else
        return res.error!
      end
    end

    # creates and/or returns the Muddyit::Collections object
    def collections() @collections ||= Muddyit::Collections.new(self) end

    # A mirror of the pages.create method, but for one off, non-stored, quick extraction
    def extract(doc, options={})

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
      api_url = "/extract"
      response = self.send_request(api_url, :post, {}, body.to_json)
      return Muddyit::Collections::Collection::Pages::Page.new(self, response)
    end
    
    protected

    # For easier testing. You can mock this method with a XML file you re expecting to receive
    def oauth_request_over_http(api_url, http_method, opts, body)

      http_opts = { "Accept" => "application/json", "Content-Type" => "application/json", "User-Agent" => "muddyit_fu" }
      query_string = opts.to_a.map {|x| x.join("=")}.join("&")

      case http_method
        when :get
          url = opts.empty? ? api_url : "#{api_url}?#{query_string}"
          @accesstoken.get(url, http_opts)
        when :post
          @accesstoken.post(api_url, body, http_opts)
        when :put
          @accesstoken.put(api_url, body, http_opts)
        when :delete
          @accesstoken.delete(api_url, http_opts)
      else
        raise 'invalid http method specified'
      end
    end

    def basic_request_over_http(path, http_method, opts, data)

      http_opts = { "Accept" => "application/json", "Content-Type" => "application/json", "User-Agent" => "muddyit_fu" }
      query_string = opts.to_a.map {|x| x.join("=")}.join("&")

      u = URI.parse(@rest_endpoint+path)

      if [:post, :put].include?(http_method)
        data.reject! { |k,v| v.nil? } if data.is_a?(Hash)
      end

      headers = http_opts

      case http_method
      when :post
        request = Net::HTTP::Post.new(path,headers)
        request.basic_auth @username, @password
        request["Content-Length"] = 0 # Default to 0
      when :put
        request = Net::HTTP::Put.new(path,headers)
        request.basic_auth @username, @password
        request["Content-Length"] = 0 # Default to 0
      when :get
        request = Net::HTTP::Get.new(path,headers)
        request.basic_auth @username, @password
      when :delete
        request =  Net::HTTP::Delete.new(path,headers)
        request.basic_auth @username, @password
      when :head
        request = Net::HTTP::Head.new(path,headers)
        request.basic_auth @username, @password
      else
        raise ArgumentError, "Don't know how to handle http_method: :#{http_method.to_s}"
      end

      if data.is_a?(Hash)
        request.set_form_data(data)
      elsif data
        if data.respond_to?(:read)
          request.body_stream = data
          if data.respond_to?(:length)
            request["Content-Length"] = data.length
          elsif data.respond_to?(:stat) && data.stat.respond_to?(:size)
            request["Content-Length"] = data.stat.size
          else
            raise ArgumentError, "Don't know how to send a body_stream that doesn't respond to .length or .stat.size"
          end
        else
          request.body = data.to_s
          request["Content-Length"] = request.body.length
        end
      end

      http = Net::HTTP.new(u.host, u.port)
      #http.open_timeout = self.http_open_timeout unless self.http_open_timeout.nil?
      #http.read_timeout = self.http_read_timeout unless self.http_read_timeout.nil?
      http.start { |http| http.request(request) }
    end

  end
end