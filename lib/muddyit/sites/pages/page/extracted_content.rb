class Muddyit::Sites::Site::Pages::Page::ExtractedContent < Muddyit::Generic

  def initialize(muddyit, attributes)
    super(muddyit, attributes)
    populate_terms
  end


  protected

  def populate_terms
    terms = []
    if @attributes.has_key?(:terms)    
      @attributes[:terms].each do |term|
         terms.push term['term']
      end
      @attributes[:terms] = terms
    end
  end

end