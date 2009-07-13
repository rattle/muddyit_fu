class Muddyit::Sites::Entity < Muddyit::Generic

  def classification
    unless @attributes[:type]
      # We merge here as we don't want to overwrite a entity specific confidence score
      @attributes.merge!(self.fetch)
    end
    @attributes[:type]
  end

  protected
  def fetch
    api_url = "/sites/#{@attributes[:site][:token]}/entities/#{URI.escape(CGI.escape(@attributes[:uri]),'.')}"
    response = @muddyit.send_request(api_url, :get)
    response.nested_symbolize_keys!
  end
  
end