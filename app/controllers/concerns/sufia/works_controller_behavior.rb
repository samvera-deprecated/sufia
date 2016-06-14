module Sufia
  module WorksControllerBehavior
    extend ActiveSupport::Concern
    include Sufia::Breadcrumbs
    include Sufia::Controller
    include CurationConcerns::CurationConcernController

    included do
      before_action :has_access?, except: :show
      before_action :build_breadcrumbs, only: [:edit, :show]
      self.curation_concern_type = GenericWork
      self.show_presenter = Sufia::WorkShowPresenter
      layout "sufia-one-column"
    end

    def new
      curation_concern.depositor = current_user.user_key
      super
    end

    protected

      # Override the default behavior from curation_concerns in order to add uploaded_files to the parameters received by the actor.
      def attributes_for_actor
        attributes = super
        # If they selected a BrowseEverything file, but then clicked the
        # remove button, it will still show up in `selected_files`, but
        # it will no longer be in uploaded_files. By checking the
        # intersection, we get the files they added via BrowseEverything
        # that they have not removed from the upload widget.
        uploaded_files = params.fetch(:uploaded_files, [])
        selected_files = params.fetch(:selected_files, {}).values
        browse_everything_urls = uploaded_files &
                                 selected_files.map { |f| f[:url] }

        # we need the hash of files with url and file_name
        browse_everything_files = selected_files
                                  .select { |v| uploaded_files.include?(v[:url]) }

        attributes[:remote_files] = browse_everything_files
        # Strip out any BrowseEverthing files from the regular uploads.
        attributes[:uploaded_files] = uploaded_files -
                                      browse_everything_urls
        attributes
      end

      def after_create_response
        respond_to do |wants|
          wants.html do
            flash[:notice] = t('sufia.generic_works.new.after_create_html', application_name: view_context.application_name)
            redirect_to [main_app, curation_concern]
          end
          wants.json { render :show, status: :created, location: polymorphic_path([main_app, curation_concern]) }
        end
      end

      # Called by CurationConcerns::CurationConcernController#show
      def additional_response_formats(format)
        format.endnote { render text: presenter.solr_document.export_as_endnote }
        document_export_formats(format)
      end

      def add_breadcrumb_for_controller
        add_breadcrumb I18n.t('sufia.dashboard.my.works'), sufia.dashboard_works_path
      end

      def add_breadcrumb_for_action
        case action_name
        when 'edit'.freeze
          add_breadcrumb I18n.t("sufia.work.browse_view"), main_app.curation_concerns_generic_work_path(params["id"])
        when 'show'.freeze
          add_breadcrumb presenter.to_s, main_app.polymorphic_path(presenter)
        end
      end

      def document_export_formats(format)
        format.any do
          format_name = params.fetch(:format, '').to_sym
          raise ActionController::UnknownFormat unless presenter.export_formats.include? format_name
          render_document_export_format format_name
        end
      end

      ##
      # Render the document export formats for a response
      # First, try to render an appropriate template (e.g. index.endnote.erb)
      # If that fails, just concatenate the document export responses with a newline.
      def render_document_export_format(format_name)
        render
      rescue ActionView::MissingTemplate
        render text: presenter.export_as(format_name), layout: false
      end
  end
end
