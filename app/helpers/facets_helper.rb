module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  def display_collection_facet
    if Sufia.config.collection_facet == :public
      return true
    elsif Sufia.config.collection_facet == :user && current_user
      return true
    else
      return false
    end
  end
end
