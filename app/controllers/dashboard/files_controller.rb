module Dashboard
  class FilesController < DashboardController
    self.solr_search_params_logic += [
      :show_only_files_deposited_by_current_user,
      :show_only_generic_files
    ]

    def index
      super
      @selected_tab = :files
    end

    def controller_name
      :dashboard
    end
  end
end
