module Sufia
  class GenericFileIndexingService < ActiveFedora::IndexingService
    STORED_INTEGER = Solrizer::Descriptor.new(:integer, :stored)

    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc[Solrizer.solr_name('label')] = object.label
        solr_doc[Solrizer.solr_name('file_format')] = object.file_format
        solr_doc[Solrizer.solr_name('file_format', :facetable)] = object.file_format
        solr_doc['all_text_timv'] = object.full_text.content
        solr_doc[Solrizer.solr_name('file_size', STORED_INTEGER)] = object.content.size.to_i
        # Index the Fedora-generated SHA1 digest to create a linkage
        # between files on disk (in fcrepo.binary-store-path) and objects
        # in the repository.
        solr_doc[Solrizer.solr_name('digest', :symbol)] = digest_from_content
        object.index_collection_ids(solr_doc) unless Sufia.config.collection_facet.nil?
      end
    end

    private

      def digest_from_content
        return unless object.content.has_content?
        object.content.digest.first.to_s
      end
  end
end
