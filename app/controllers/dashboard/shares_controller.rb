module Dashboard
  class SharesController < DashboardController
    self.solr_search_params_logic += [
      :show_only_shared_files
    ]

    def show_only_shared_files(solr_parameters, user_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] += [
        "-" + ActiveFedora::SolrService.construct_query_for_rel(depositor: current_user.user_key),
        ActiveFedora::SolrService.construct_query_for_rel(has_model: GenericFile.to_class_uri)
      ]
    end

    def index
      super
      @selected_tab = :shares
    end

    def controller_name
      :dashboard
    end
  end
end
