class Muddyit::Sites::Site::Entities < Muddyit::Generic
  # Placeholder

  # retrieve entities related to the specified entity within the site entities collection
  #
  # Params
  # * options (Optional)
  #
  def find_related(uri, options = {})

    raise if uri.nil?
    api_url = "/sites/#{self.site.attributes[:token]}/entities/#{Digest::MD5.hexdigest(uri)}/related"
    response = @muddyit.send_request(api_url, :get, options)

    results = []
    response.each { |result|
      results.push :count => result.delete('count'), :entity => Muddyit::Sites::Site::Entities::Entity.new(@muddyit, result)
    }
    return results
  end
  
end
