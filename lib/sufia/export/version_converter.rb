module Sufia
  module Export
    # Convert a single version of a GenericFile content into a PORO so that the metadata
    #  ()including pointers to the version content) can be exported in json format using to_json
    #
    # @attr_reader [String] uri     location of version in fedora (also id of version)
    # @attr_reader [String] label   version label extracted from the graph for the version identified by the url
    # @attr_reader [String] created version creation date extracted from the graph for the version identified by the url
    class VersionConverter
      attr_reader :uri, :label, :created

      # Create an instance of a GenericFile version containing all the metadata for json export
      #
      # @param [String] uri location of version to be converted in fedora (also id of version)
      # @param [ActiveFedora::VersionsGraph] version_graph the graph of versions associated with one GenericFile (gf.content.versions)
      def initialize(uri, version_graph)
        @uri = uri
        @created = find_triple(RDF::Vocab::Fcrepo4.created, version_graph)
        @label = find_triple(RDF::Vocab::Fcrepo4.hasVersionLabel, version_graph)
      end

      private

        def find_triple(predicate, graph)
          triple = graph.find { |t| t.subject == uri && t.predicate == predicate }
          triple.object.to_s
        end
    end
  end
end
