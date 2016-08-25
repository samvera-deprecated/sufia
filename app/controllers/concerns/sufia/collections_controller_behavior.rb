module Sufia
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern
    include Sufia::Breadcrumbs

    included do
      before_action :build_breadcrumbs, only: [:edit, :show]
      layout "sufia-one-column"
      # include the render_check_all view helper method
      helper ::BatchEditsHelper
      # include the display_trophy_link view helper method
      helper Sufia::TrophyHelper
      # include the present_terms view helper method
      helper ::FileSetHelper
      self.presenter_class = Sufia::CollectionPresenter
      self.form_class = Sufia::Forms::CollectionForm
    end

    protected

      def add_breadcrumb_for_controller
        add_breadcrumb I18n.t('sufia.dashboard.my.collections'), sufia.dashboard_collections_path
      end

      def add_breadcrumb_for_action
        case action_name
        when 'edit'.freeze
          add_breadcrumb I18n.t("sufia.collection.browse_view"), main_app.collection_path(params["id"])
        when 'show'.freeze
          add_breadcrumb presenter.to_s, main_app.polymorphic_path(presenter)
        end
      end
  end
end
