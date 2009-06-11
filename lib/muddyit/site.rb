class Muddyit::Sites::Site < Muddyit::Generic

  # get pages object for site
  #
  def pages() @pages ||= Muddyit::Sites::Site::Pages.new(@muddyit, :site => self) end
  
  protected
  def fetch
    api_url = "/sites/#{@attributes[:token]}"
    response = @muddyit.send_request(api_url, :get, {})
    response['site'].nested_symbolize_keys!
  end

end