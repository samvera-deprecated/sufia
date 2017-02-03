module Sufia
  module WorkBehavior
    extend ActiveSupport::Concern
    include Sufia::ProxyDeposit
    include Sufia::Works::Trophies
    include Sufia::Works::Metadata
    include Sufia::Works::Featured
    include Sufia::WithEvents

    included do
      self.indexer = Sufia::WorkIndexer
    end

    # TODO: Move this into ActiveFedora
    def etag
      raise "Unable to produce an etag for a unsaved object" unless persisted?
      ldp_source.head.etag
    end
  end
end
