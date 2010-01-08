class Muddyit::Collections::Collection::Entities < Muddyit::Generic
  # Placeholder

  # retrieve entities related to the specified entity within the collection entities collection
  #
  # Params
  # * options (Optional)
  #
  def find_related(uri, options = {})

    raise if uri.nil?
    api_url = "/collections/#{self.collection.attributes[:token]}/entities/#{Digest::MD5.hexdigest(uri)}/related"
    response = @muddyit.send_request(api_url, :get, options)

    results = []
    response.each { |result|
      results.push :count => result.delete('count'), :entity => Muddyit::Collections::Collection::Entities::Entity.new(@muddyit, result)
    }
    return results
  end
  
end
