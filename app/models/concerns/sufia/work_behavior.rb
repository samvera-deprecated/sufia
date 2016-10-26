module Sufia
  module WorkBehavior
    extend ActiveSupport::Concern
    include Sufia::ProxyDeposit
    include Sufia::Works::Trophies
    include Sufia::Works::Metadata
    include Sufia::Works::Featured
    include Sufia::WithEvents
    include Sufia::Publishable

    included do
      self.indexer = Sufia::WorkIndexer
    end
  end
end
