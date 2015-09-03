module CurationConcerns
  module Forms
    class CollectionEditForm
      include HydraEditor::Form
      self.model_class = ::Collection
      self.terms = [:resource_type, :title, :creator, :contributor, :description, :tag, :rights,
                    :publisher, :date_created, :subject, :language, :identifier, :based_near, :related_url]

      # Test to see if the given field is required
      # @param [Symbol] key a field
      # @return [Boolean] is it required or not
      def required?(key)
        model_class.validators_on(key).any? { |v| v.is_a? ActiveModel::Validations::PresenceValidator }
      end

      # @return [Hash] All generic files in the collection, file.to_s is the key, file.id is the value
      def select_files
        Hash[all_files]
      end

      private

        def all_files
          member_presenters.flat_map(&:file_presenters).map { |x| [x.to_s, x.id] }
        end

        def member_presenters
          load_generic_work_presenters(model.member_ids)
        end

        # @param [Array] ids the list of ids to load
        # @return [Array<GenericFilePresenter>] presenters for the generic files in order of the ids
        def load_generic_work_presenters(ids)
          return [] if ids.blank?
          docs = ActiveFedora::SolrService.query("{!terms f=id}#{ids.join(',')}").map { |res| SolrDocument.new(res) }
          ids.map { |id| GenericWorkShowPresenter.new(docs.find { |doc| doc.id == id }, nil) }
        end
    end
  end
end