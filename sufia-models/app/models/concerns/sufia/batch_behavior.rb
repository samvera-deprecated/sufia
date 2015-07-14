module Sufia
  module BatchBehavior
    extend ActiveSupport::Concern
    include Hydra::AccessControls::Permissions
    include CurationConcerns::Noid

    included do
      has_many :generic_files, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf, class_name:"GenericFile"

      property :creator, predicate: ::RDF::DC.creator
      property :title, predicate: ::RDF::DC.title
      property :status, predicate: ::RDF::DC.type
    end

    module ClassMethods
      def find_or_create(id)
        begin
          Batch.find(id)
        rescue ActiveFedora::ObjectNotFoundError
          safe_create(id)
        end
      end

      private

      # This method handles most race conditions gracefully.
      # If a batch with the same ID is created by another thread
      # we fetch the batch that was created (rather than throwing
      # an error) and continute.
      def safe_create(id)
        begin
          Batch.create(id: id)
        rescue ActiveFedora::IllegalOperation => ex
          # This is the exception thrown by LDP when we attempt to
          # create a duplicate object. If we can find the object
          # then we are good to go.
          Batch.find(id)
        end
      end
    end

  end
end