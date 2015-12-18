module Sufia
  module FacetsHelperBehavior
    extend ActiveSupport::Concern

    def display_collection_facet
      if Sufia.config.collection_facet == :public
        true
      elsif Sufia.config.collection_facet == :user && current_user
        true
      else
        false
      end
    end
  end
end
