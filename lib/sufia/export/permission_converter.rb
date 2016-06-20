module Sufia
  module Export
    # Convert a permission record from a ActiveFedora:Base into a PORO so that the metadata
    #  can be exported in json format using to_json
    #
    class PermissionConverter
      # Create an instance of a Object Permission containing all the metadata for the permission
      #
      # @param [Hydra::AccessControls::Permission] permission the permission associated with one access record
      def initialize(permission)
        @id = permission.id
        @agent = permission.agent.first.rdf_subject.to_s
        @mode = permission.mode.first.rdf_subject.to_s
        # Using .id instead of .uri allows us to rebuild the URI later on with a new base URI
        @access_to = permission.access_to.id
      end
    end
  end
end
