module Sufia::Import
  # Imports a Sufia 6.0-exported Collection into a Sufia PCDM Collection
  class CollectionTranslator < Translator
    def initialize(settings)
      super
      @collection_builder = CollectionBuilder.new
    end

    private

      def build_from_json(json)
        collection = @collection_builder.build(json)
        collection.save
      end

      def default_prefix
        "collection_"
      end
  end
end
