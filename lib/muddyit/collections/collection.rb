class Muddyit::Collections::Collection < Muddyit::Generic

  # get pages object for collection
  #
  def pages() @pages ||= Muddyit::Collections::Collection::Pages.new(@muddyit, :collection => self) end
  def entities() @entities ||= Muddyit::Collections::Collection::Entities.new(@muddyit, :collection => self) end
  
  protected
  def fetch
    api_url = "/collections/#{@attributes[:token]}"
    response = @muddyit.send_request(api_url, :get, {})
    response['collections'].nested_symbolize_keys!
  end

end