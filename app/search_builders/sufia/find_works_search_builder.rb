class Sufia::FindWorksSearchBuilder < Sufia::SearchBuilder
  include Sufia::MySearchBuilderBehavior
  include CurationConcerns::FilterByType

  self.default_processor_chain += [:add_advanced_search_to_solr, :show_only_resources_deposited_by_current_user]

  def only_works?
    true
  end
end
