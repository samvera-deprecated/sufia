# TODO: This is module is here while we introduce works into Sufia.
#       It should be removed once we update the rest of the system 
#       to provide this functionality.  
module Sufia::Works
  module CurationConcern
    module WithBasicMetadata
      extend ActiveSupport::Concern

      included do 
        property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false
      end

      def collection?
        false
      end

      def generic_work?
        true
      end
    end
  end
end