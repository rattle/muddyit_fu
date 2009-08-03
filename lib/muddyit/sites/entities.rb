class Muddyit::Sites::Site::Entities
  # Placeholder

  # retrieve entities related to the specified entity within the site entities collection
  #
  # Params
  # * options (Optional)
  #
  def related(uri, options = {})
    raise if uri.nil?
    api_url = "/sites/#{self.site.attributes[:token]}/entities/#{Digest::MD5.hexdigest(URI.encode(uri))}/related"
    response = @muddyit.send_request(api_url, :get, options)

    results = []
    response.each { |result|
      # The return format needs sorting out here .......
      results.push Muddyit::Sites::Site::Entities::Entity.new(@muddyit, result)
    }
    return results
  end
  
end
