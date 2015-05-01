module Sufia::Works
  module CurationConcern
    module WithGenericFiles
      extend ActiveSupport::Concern

      included do
        # This used to have a hasFile relation when in hydra-works.  That does not seem to exist so I am using hasPart instead
        has_and_belongs_to_many :files, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.hasPart, class_name: "GenericFile"
        before_destroy :before_destroy_cleanup_generic_files
      end

      def before_destroy_cleanup_generic_files
        files.each(&:destroy)
      end
    end
  end
end
