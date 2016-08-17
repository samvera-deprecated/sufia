module Sufia
  class FileSetIndexer < CurationConcerns::FileSetIndexer
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc[Solrizer.solr_name('page_count')] = object.page_count
        solr_doc[Solrizer.solr_name('file_title')] = object.file_title
        solr_doc[Solrizer.solr_name('duration')] = object.duration
        solr_doc[Solrizer.solr_name('sample_rate')] = object.sample_rate
      end
    end
  end
end
