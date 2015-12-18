class Batch < ActiveFedora::Base
  include Hydra::AccessControls::Permissions
  include Sufia::ModelMethods
  include Sufia::Noid
  extend Sufia::Lockable

  has_many :generic_files, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :creator, predicate: ::RDF::DC.creator
  property :title, predicate: ::RDF::DC.title
  property :status, predicate: ::RDF::DC.type

  # This method handles most race conditions gracefully.
  def self.find_or_create(id)
    acquire_lock_for(id) do
      begin
        Batch.find(id)
      rescue ActiveFedora::ObjectNotFoundError
        Batch.create(id: id)
      end
    end
  end
end
