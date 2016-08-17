module Sufia
  module FileSetBehavior
    extend ActiveSupport::Concern
    include Sufia::WithEvents

    # Cast to a SolrDocument by querying from Solr
    def to_presenter
      CatalogController.new.fetch(id).last
    end

    included do
      self.characterization_terms += [:duration, :sample_rate]
      delegate(*characterization_terms, to: :characterization_proxy)

      self.indexer = Sufia::FileSetIndexer
    end
  end
end
