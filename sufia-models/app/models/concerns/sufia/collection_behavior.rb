module Sufia
  module CollectionBehavior
    extend ActiveSupport::Concern
    include Hydra::Collection
    include Sufia::ModelMethods
    include Sufia::Noid
    include Sufia::GenericFile::Permissions

    included do
      before_save :update_permissions
      validates :title, presence: true
    end

    def update_permissions
      self.visibility = "open"
    end

    # Compute the sum of each file in the collection using Solr to
    # avoid having to proces GBs of data for a simple number. Can be
    # cleaned up once it is confirmed to work
    #
    # Return an integer of the result
    def bytes
      query = "has_model_ssim:GenericFile"
      # Cribbed from Hydra::Collections to speed up the resolution
      # process
      args = {
        :fq => "{!join from=hasCollectionMember_ssim to=id}id:#{self.id}",
        :fl => "id,file_size_isi",
        :rows => self.members.count
      }

      files = ActiveFedora::SolrService.query(query, args)
      # Skip any files which have not yet been processed and will 
      # otherwise return an error
      return files.reduce(0) { |sum, f| sum += f['file_size_isi'] unless f['file_size_isi'].nil? } 
    end
  end
end
