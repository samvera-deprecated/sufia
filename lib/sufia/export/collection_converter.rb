module Sufia
  module Export
    # Convert a Collection including metadata, permissions and member ids into a PORO
    # so that the metadata can be exported in json format using to_json
    #
    class CollectionConverter < Converter
      # Create an instance of a Collection converter containing all the metadata for json export
      #
      # @param [Collection] collection to be converted for export
      def initialize(collection)
        @id = collection.id
        @title = collection.title
        @description = collection.description
        @depositor = collection.depositor
        @creator = collection.creator.map { |c| c }
        @members = collection.members.map(&:id)
        @permissions = permissions(collection)
      end
    end
  end
end
