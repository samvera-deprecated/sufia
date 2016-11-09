# Class to extract all the ids from fedora for registered classes.  By default GenericFile and Collection are registered.
#
module Sufia
  module Migration
    module Survey
      class FedoraIdService
        attr_accessor :model_registry

        # initialize the service with the default models (GenericFile & Collection) registered
        def initialize
          @model_registry = default_registry
        end

        # regesiter an additional ActiveFedora Model to extract ids for
        #
        # @param [Class] model_class additional class that you would like to be in the output
        # @raise [RegistryError] if the class is not an ActiveFedora based class
        def register_model(model_class)
          raise(RegistryError, "Model (#{model_class.name}) for conversion must be an ActiveFedora::Base") unless model_class.ancestors.include?(ActiveFedora::Base)
          return if @model_registry.include? model_class
          @model_registry << model_class
        end

        # returns a list of ids for all the registered classes in the repository
        #
        # @param [Number] limit limits the number of results (default is all)
        def call(limit = :all)
          ids = all_ids.select { |id| registered_model?(id) }
          return ids if limit == :all
          ids.take(limit)
        end

        private

          def default_registry
            [::GenericFile, ::Collection]
          end

          def all_ids
            root_uri = ActiveFedora.fedora.host + ActiveFedora.fedora.base_path
            # Fetches all the Fedora 4 descendant URIs for a given URI.
            # Stolen from: https://github.com/projecthydra/active_fedora/blob/master/lib/active_fedora/indexing.rb#L72-L79
            resource = Ldp::Resource::RdfSource.new(ActiveFedora.fedora.connection, root_uri)
            children = resource.graph.query(predicate: ::RDF::Vocab::LDP.contains).map { |descendant| descendant.object.to_s }
            children.map { |uri| uri.split("/").last }
          end

          def active_fedora_model(id)
            query = 'id:"' + id + '"'
            matches = ActiveFedora::SolrService.query(query)
            return nil if matches.count == 0
            model_str = matches.first["has_model_ssim"]
            model_str = model_str.first if model_str.is_a?(Array)
            if model_str.blank? || !Object.const_defined?(model_str)
              Rails.logger.error("Invalid model #{id} #{model_str}")
              return nil
            end
            Object.const_get(model_str)
          end

          def registered_model?(id)
            model_registry.include?(active_fedora_model(id))
          end
      end
      class RegistryError < RuntimeError; end
    end
  end
end
