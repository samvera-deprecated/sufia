module Sufia
  module Export
    # Convert a GenericFile including metadata, permissions and version metadata into a PORO
    # so that the metadata can be exported in json format using to_json
    #
    class Actor
      attr_reader :converter_registry, :limit, :ids
      attr_accessor :conversion_count

      # initialize the class with the default registry
      def initialize
        @converter_registry = default_registry
      end

      # register a converter for a new class or overwrite the converter for a default class
      #
      # @param [Class] model_class     The ActiveFedora model class to be converter to json
      # @param [Class] converter_class The class that will convert from ActiveFedora to json
      def register_converter(model_class, converter_class)
        raise(RegistryError, "Model (#{model_class.name}) for conversion must be an ActiveFedora::Base") unless model_class.ancestors.include?(ActiveFedora::Base)
        raise(RegistryError, "Converter (#{converter_class.name}) for conversion must be an Sufia::Export::Converter") unless converter_class.ancestors.include?(Sufia::Export::Converter)
        converter_registry[model_class] = converter_class
      end

      # Convert the classes using the registered converters from ActiveFedora to json files
      #
      # @param [Array] model_class_list list of classes to be converter
      # @param [Hash]  opts
      # @option opts [Number] :limit Limits the number of conversion done (defaults to -1 or all)
      # @option opts [Array]  :ids   List of ids to be converted.  Can be from any model
      def call(model_class_list = converter_registry.keys, opts = {})
        @conversion_count = 0
        validate_class_list(model_class_list)
        parse_options(opts)
        export_models(model_class_list)
      end

      private

        def parse_options(opts)
          @limit = opts[:limit] || -1
          @ids = opts[:ids]
        end

        def model_scope(model_class)
          scope = model_class.all
          scope  = scope.where(id: ids) unless ids.blank?
          scope  = scope.limit(limit - conversion_count) unless limit == -1
          scope
        end

        def validate_class_list(model_class_list)
          model_class_list.each do |model_class|
            converter_class = converter_registry[model_class]
            raise(RegistryError, "Undefined Model for conversion (#{model_class.name})") if converter_class.blank?
          end
        end

        def export_models(model_class_list)
          model_class_list.each do |model_class|
            converter_class = converter_registry[model_class]
            export_model_list(model_scope(model_class), converter_class)
          end
        end

        def export_model_list(model_list, converter_class)
          model_list.each do |model|
            export_one(converter_class, model)
          end
        end

        def export_one(converter_class, model)
          converter = converter_class.new(model)
          path = file_name(model)
          json = converter.to_json(pretty: true)
          File.write(path, json)
          @conversion_count += 1
        end

        def file_name(model)
          File.join(file_path, "#{model.class.name.underscore}_#{model.id}.json")
        end

        def default_registry
          { ::GenericFile => Sufia::Export::GenericFileConverter, ::Collection => Sufia::Export::CollectionConverter }
        end

        def file_path
          return @file_path unless @file_path.blank?
          @file_path = "tmp/export"
          FileUtils.mkdir_p @file_path
          @file_path
        end
    end

    class RegistryError < RuntimeError; end
  end
end
