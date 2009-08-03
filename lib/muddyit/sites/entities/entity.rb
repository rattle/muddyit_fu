class Muddyit::Sites::Site::Entities::Entity < Muddyit::Generic

  def classification
    unless @attributes[:type]
      # We merge here as we don't want to overwrite a entity specific confidence score
      @attributes.merge!(self.fetch)
    end
    @attributes[:type]
  end

  # retrieve entities related to the specified entity within the site entities collection
  #
  # Params
  # * options (Optional)
  #
  def related(options = {})
    api_url = "/sites/#{self.site.attributes[:token]}/entities/#{Digest::MD5.hexdigest(URI.encode(@attributes[:uri]))}/related"
    response = @muddyit.send_request(api_url, :get, options)

    results = []
    response.each { |result|
      # The return format needs sorting out here .......
      results.push Muddyit::Sites::Site::Entities::Entity.new(@muddyit, result)
    }
    return results
  end

  protected
  def fetch
    api_url = "/sites/#{@attributes[:site][:token]}/entities/#{Digest::MD5.hexdigest(URI.encode(@attributes[:uri]))}"
    response = @muddyit.send_request(api_url, :get)
    response.nested_symbolize_keys!
  end
  
end