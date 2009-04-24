module Muddyit

  def self.new(*params)
    Muddyit::Base.new(*params)
  end

  class Base
    class_attr_accessor :http_open_timeout
    class_attr_accessor :http_read_timeout
    attr_accessor :rest_endpoint
    attr_reader :access_key_id, :secret_access_key

    @@http_open_timeout = 60
    @@http_read_timeout = 60

    REST_ENDPOINT = 'http://www.muddy.it/api'

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
    # * :access_key_id (Required)
    #     the access key id
    # * :secret_access_key (Required)
    #     the secret access key
    # * :rest_endpoint (Optional)
    #     the muddy.it rest service endpoint
    # or:
    # * config_file (Required)
    #     yaml file to load configuration from
    #
    # Config Example (yaml file)
    # ---
    # access_key_id: YOUR_ACCESS_KEY_ID
    # secret_access_key: YOUR_SECRET_ACCESS_KEY
    #
    def initialize(config_hash_or_file)
      if config_hash_or_file.is_a? Hash
        config_hash_or_file.nested_symbolize_keys!
        @access_key_id = config_hash_or_file[:access_key_id]
        @secret_access_key = config_hash_or_file[:secret_access_key]
        @rest_endpoint = config_hash_or_file.has_key?(:rest_endpoint) ? config_hash_or_file[:rest_endpoint] : REST_ENDPOINT
        raise 'config_hash must contain access_key_id and secret_access_key' unless @access_key_id and @secret_access_key
      else
        config = YAML.load_file(config_hash_or_file)
        config.nested_symbolize_keys!
        @access_key_id = config[:access_key_id]
        @secret_access_key = config[:secret_access_key]
        @rest_endpoint = config.has_key?(:rest_endpoint) ? config[:rest_endpoint] : REST_ENDPOINT
        raise 'config file must contain access_key_id and secret_access_key' unless @access_key_id and @secret_access_key
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
    def send_request(api_url, http_method = :get, options= {})

      raise 'no api_url supplied' unless api_url

      res = request_over_http(api_url, http_method, options)
      # Strip any js wrapping methods
      #puts res.body
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
    def request_over_http(api_url, http_method, options)

      req = nil
      http_opts = { "Accept" => "application/json", "User-Agent" => "muddyit_fu" }
      url = URI.parse(api_url)

      case http_method
        when :get
          u = url.query.nil? ? url.path : url.path+"?"+url.query
          req = Net::HTTP::Get.new(u, http_opts)
        when :post
          req = Net::HTTP::Post.new(url.path, http_opts)
        when :put
          req = Net::HTTP::Put.new(url.path, http_opts)
        when :delete
          req = Net::HTTP::Delete.new(url.path, http_opts)
      else
        raise 'invalid http method specified'
      end

      options = calculate_signature(http_method, url.path, options)
      req.set_form_data(options) unless options.keys.empty?
      #req.basic_auth @username, @password

      http = Net::HTTP.new(url.host, url.port)
      http.open_timeout = @@http_open_timeout
      http.read_timeout = @@http_read_timeout
      http.start do |http|
        res = http.request(req)
        case res
        when Net::HTTPSuccess
          return res
        else
          raise Muddyit::Errors.error_for(res.code, 'HTTP Error')
        end
      end
    
    end

    # aws request signature methods, taken from http://rightscale.rubyforge.org/right_aws_gem_doc

    def calculate_signature(http_verb, url, options)
      endpoint = URI.parse(@rest_endpoint)
      options.nested_stringify_keys!
      options.delete('Signature')
      options['AccessKeyId'] = @access_key_id
      options['Signature'] = sign_request_v2(@secret_access_key, options, http_verb.to_s, endpoint.host, url)

      return options
    end

    def signed_service_params(aws_secret_access_key, service_hash, http_verb, host, uri)
      sign_request_v2(aws_secret_access_key, service_hash, http_verb, host, uri)
    end

    def sign_request_v2(aws_secret_access_key, service_hash, http_verb, host, uri)
      fix_service_params(service_hash, '2')
      # select a signing method (make an old openssl working with sha1)
      # make 'HmacSHA256' to be a default one
      service_hash['SignatureMethod'] = 'HmacSHA256' unless ['HmacSHA256', 'HmacSHA1'].include?(service_hash['SignatureMethod'])
      service_hash['SignatureMethod'] = 'HmacSHA1'   unless @@digest256
      # select a digest
      digest = (service_hash['SignatureMethod'] == 'HmacSHA256' ? @@digest256 : @@digest1)
      # form string to sign
      canonical_string = service_hash.keys.sort.map do |key|
        "#{amz_escape(key)}=#{amz_escape(service_hash[key])}"
      end.join('&')
      string_to_sign = "#{http_verb.to_s.upcase}\n#{host.downcase}\n#{uri}\n#{canonical_string}"

      # sign the string
      amz_escape(Base64.encode64(OpenSSL::HMAC.digest(digest, aws_secret_access_key, string_to_sign)).strip)
    end

    # Set a timestamp and a signature version
    def fix_service_params(service_hash, signature)
      service_hash["Timestamp"] ||= Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.000Z") unless service_hash["Expires"]
      service_hash["SignatureVersion"] = signature
      service_hash
    end

    # Escape a string accordingly Amazon rulles
    # http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/index.html?REST_RESTAuth.html
    def amz_escape(param)
      param.to_s.gsub(/([^a-zA-Z0-9._~-]+)/n) do
        '%' + $1.unpack('H2' * $1.size).join('%').upcase
      end
    end


  end
end