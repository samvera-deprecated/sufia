module Qa::Authorities
  class Local::FindWorks < ActiveFedora::Base

    attr_reader :q

    def initialize(q)
      @q = q
    end

    # TODO: Limit results to not self, editable, no existing parents, and no existing children

    def search(q, controller)

      repo = CatalogController.new.repository
      builder = Sufia::FindWorksSearchBuilder.new(controller)
      response = repo.search(builder)
      docs = response.documents
      results = []
      docs.each do |doc|
        id = doc.id
        title = doc.title
        results.push(id: id, label: title, value: id)
      end
      results
    end
  end
end
