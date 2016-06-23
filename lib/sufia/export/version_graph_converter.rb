module Sufia
  module Export
    # Convert a graph of versions from a GenericFile into a list of POROs so that the metadata
    #  (including pointers to the version content) can be exported in json format using to_json
    #
    # @attr_reader [Array<VersionConverter] versions list of VersionConverters extracted from the graph
    class VersionGraphConverter
      attr_reader :versions

      # Create an instance of a GenericFile version graph containing all the metadata for each version
      #
      # @param [ActiveFedora::VersionsGraph] version_graph the graph of versions associated with one GenericFile (gf.content.versions)
      def initialize(version_graph)
        @versions = []
        parse(version_graph)
      end

      private

        def parse(graph)
          find_uris(graph).each do |uri|
            versions << VersionConverter.new(uri, graph)
          end
        end

        def find_uris(graph)
          uris = []
          graph.query(predicate: RDF::Vocab::Fcrepo4.hasVersion).each do |triple|
            uris << triple.object.to_s
          end
          uris
        end
    end
  end
end
