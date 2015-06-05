module Sufia
  class GenericFileIndexingService < ActiveFedora::IndexingService
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc[Solrizer.solr_name('label')] = object.label
        solr_doc[Solrizer.solr_name('file_format')] = object.file_format
        solr_doc[Solrizer.solr_name('file_format', :facetable)] = object.file_format
        solr_doc['all_text_timv'] = object.full_text.content

        int_store = Solrizer::Descriptor.new(:integer, :indexed, :stored);
        solr_doc[Solrizer.solr_name('file_size', int_store)] = object.content.size.to_i
      end
    end
  end
end
