module Sufia
  module CollectionBehavior
    extend ActiveSupport::Concern
    include Hydra::Collection
    include Sufia::ModelMethods
    include Sufia::Noid
    include Sufia::GenericFile::Permissions

    included do
      validates :title, presence: true
    end

    # Compute the sum of each file in the collection using Solr to
    # avoid having to hit Fedora
    #
    # @return [Fixnum] size of collection in bytes
    # @raise [RuntimeError] unsaved record does not exist in solr
    def bytes
      rows = members.count
      return 0 if rows == 0

      raise "Collection must be saved to query for bytes" if new_record?

      query = ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: file_model)
      args = {
        fq: "{!join from=hasCollectionMember_ssim to=id}id:#{id}",
        fl: "id, #{file_size_field}",
        rows: rows
      }

      files = ActiveFedora::SolrService.query(query, args)
      files.reduce(0) { |sum, f| sum + f[file_size_field].to_i }
    end

    protected

      # Field to look up when locating the size of each file in Solr.
      # Override for your own installation if using something different
      def file_size_field
        Solrizer.solr_name('file_size', stored_integer_descriptor)
      end

      # Override if you are storing your file size in a different way
      def stored_integer_descriptor
        Sufia::GenericFileIndexingService::STORED_INTEGER
      end

      # Override if not using GenericFiles
      def file_model
        ::GenericFile.to_class_uri
      end
  end
end
