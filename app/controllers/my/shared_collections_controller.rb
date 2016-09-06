module My
  class SharedCollectionsController < MyController
    self.search_params_logic += [
      :show_only_shared_collections,
      :show_only_collections
    ]

    def index
      super
      @selected_tab = :shared_collections
    end

    protected

      def search_action_url(*args)
        sufia.dashboard_shared_collections_url(*args)
      end
  end
end
