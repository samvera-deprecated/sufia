class FeaturedWorkList
  include ActiveModel::Model

  def featured_works_attributes=(attributes_collection)
    attributes_collection = attributes_collection.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes } if attributes_collection.is_a? Hash
    attributes_collection.each do |attributes|
      attributes = attributes.with_indifferent_access
      raise "Missing id" if attributes['id'].blank?
      existing_record = FeaturedWork.find(attributes['id'])
      existing_record.update(attributes.except('id'))
    end
  end

  def featured_works
    return @works if @works
    @works = FeaturedWork.all
    add_solr_document_to_works
    @works = @works.reject do |work|
      work.destroy if work.work_solr_document.blank?
      work.work_solr_document.blank?
    end
  end

  delegate :empty?, to: :featured_works

  private

    def add_solr_document_to_works
      solr_docs.each do |doc|
        work_with_id(doc['id']).work_solr_document = SolrDocument.new(doc)
      end
    end

    def ids
      @works.pluck(:work_id)
    end

    def solr_docs
      ActiveFedora::SolrService.query(ActiveFedora::SolrQueryBuilder.construct_query_for_ids(ids))
    end

    def work_with_id(id)
      @works.find { |w| w.work_id == id }
    end
end
