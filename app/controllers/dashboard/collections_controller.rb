module Dashboard
  class CollectionsController < DashboardController
    self.solr_search_params_logic += [
      :show_only_files_deposited_by_current_user,
      :show_only_collections
    ]

    def show_only_collections(solr_parameters, user_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] += [
        ActiveFedora::SolrService.construct_query_for_rel(has_model: Collection.to_class_uri)
      ]
    end

    def index
      super
      @selected_tab = :collections
    end

    def controller_name
      :dashboard
    end
  end
end
