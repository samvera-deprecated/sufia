module Qa::Authorities
  class Local::FindWorks < ActiveFedora::Base

    attr_reader :q

    def initialize(q)
      @q = q
    end

    # TODO: Limit results to not self, editable, no existing parents, and no existing children
    # Questions:
    #  1. Should/can a Search Builder be used here?
    #  2. How can the work ID and current user info be retrieved?
    def search(q, controller)

=begin
      results = []
      ActiveFedora::SolrService.query("{!field f=title_tesim}#{q}", fl: [:id, :title_tesim]).each do |result|
        id = result.fetch("id")
        results.push(id: id, label: result.fetch("title_tesim").first, value: id)
      end
=end

      puts "Controller: " + controller.object_id.to_s

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
