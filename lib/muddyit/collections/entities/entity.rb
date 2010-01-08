class Muddyit::Collections::Collection::Entities::Entity < Muddyit::Generic

#  def classification
#    unless @attributes[:type]
#      # We merge here as we don't want to overwrite a entity specific confidence score
#      @attributes.merge!(self.fetch)
#    end
#    @attributes[:type]
#  end

  # retrieve entities related to the specified entity within the collection entities collection
  #
  # Params
  # * options (Optional)
  #
  def related(options = {})
    api_url = "/collections/#{self.collection.attributes[:token]}/entities/#{Digest::MD5.hexdigest(@attributes[:uri])}/related"
    response = @muddyit.send_request(api_url, :get, options)

    results = []
    response.each { |result|
      # The return format needs sorting out here .......
      results.push Muddyit::Collections::Collection::Entities::Entity.new(@muddyit, result)
    }
    return results
  end

  protected
  def fetch
    api_url = "/collections/#{@attributes[:collection].token}/entities/#{Digest::MD5.hexdigest(@attributes[:uri])}"
    response = @muddyit.send_request(api_url, :get)
    response.nested_symbolize_keys!
  end
  
end