module Muddyit

  def self.new(*params)
    Muddyit::Base.new(*params)
  end

  class Base
    class_attr_accessor :http_open_timeout
    class_attr_accessor :http_read_timeout
    attr_accessor :rest_endpoint
    attr_reader :consumer_key, :consumer_secret, :access_token, :access_token_secret

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
        @consumer_key = config_hash_or_file[:consumer_key]
        @consumer_secret = config_hash_or_file[:consumer_secret]
        @access_token = config_hash_or_file[:access_token]
        @access_token_secret = config_hash_or_file[:access_token_secret]
        @rest_endpoint = config_hash_or_file.has_key?(:rest_endpoint) ? config_hash_or_file[:rest_endpoint] : REST_ENDPOINT
        raise 'config_hash must contain consumer_key and consumer_secret' unless @consumer_key and @consumer_secret
      else
        config = YAML.load_file(config_hash_or_file)
        config.nested_symbolize_keys!
        @consumer_key = config[:consumer_key]
        @consumer_secret = config[:consumer_secret]
        @access_token = config[:access_token]
        @access_token_secret = config[:access_token_secret]
        @rest_endpoint = config.has_key?(:rest_endpoint) ? config[:rest_endpoint] : REST_ENDPOINT
        raise 'config file must contain consumer_key and consumer_secret' unless @consumer_key and @consumer_secret
      end

      @consumer = ::OAuth::Consumer.new(@consumer_key, @consumer_secret, {:site=>@rest_endpoint})
      @accesstoken = ::OAuth::AccessToken.new(@consumer, @access_token, @access_token_secret)

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
      res = request_over_http(api_url, http_method, opts, body)
      # Strip any js wrapping methods

      if res.body =~ /^.+\((.+)\)$/
        r = JSON.parse($1)
      else
        r = JSON.parse(res.body)
      end
      
      return r
    end


    # creates and/or returns the Muddyit::Sites object
    def sites() @sites ||= Muddyit::Sites.new(self) end

    protected

    # For easier testing. You can mock this method with a XML file you re expecting to receive
    def request_over_http(api_url, http_method, opts, body)

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

  end
end