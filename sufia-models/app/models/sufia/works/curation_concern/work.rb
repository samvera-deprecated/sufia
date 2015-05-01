module Sufia::Works
  module CurationConcern
    module Work
      extend ActiveSupport::Concern
      include WithGenericFiles
      include WithEditors
      include HumanReadableType
      include Sufia::Noid
      include Sufia::ModelMethods
      include Hydra::Collections::Collectible
      include Solrizer::Common
    end
  end
end
