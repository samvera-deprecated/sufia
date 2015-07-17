module CurationConcerns::GenericWorkBehavior
  extend ActiveSupport::Concern

  include Hydra::Works::GenericWorkBehavior
  include ::CurationConcerns::HumanReadableType
  include CurationConcerns::Noid
  include CurationConcerns::Permissions
  include CurationConcerns::Serializers
  include Hydra::WithDepositor
  include Hydra::Collections::Collectible
  include Solrizer::Common
  include ::CurationConcerns::HasRepresentative
  include ::CurationConcerns::WithGenericFiles
  include Hydra::AccessControls::Embargoable

  included do
    property :owner, predicate: RDF::URI.new('http://opaquenamespace.org/ns/hydra/owner'), multiple: false
    class_attribute :human_readable_short_description
    attr_accessor :files
  end

  module ClassMethods
    def indexer
      CurationConcerns::GenericWorkIndexingService
    end
  end

  def to_solr(solr_doc={}, opts={})
    super(solr_doc).tap do |solr_doc|
      Solrizer.set_field(solr_doc, 'generic_type', 'Work', :facetable)
    end
  end

  def to_s
    title.join(', ')
  end

  # Returns a string identifying the path associated with the object. ActionPack uses this to find a suitable partial to represent the object.
  def to_partial_path
    "curation_concerns/#{super}"
  end

  def can_be_member_of_collection?(collection)
    true
  end
end