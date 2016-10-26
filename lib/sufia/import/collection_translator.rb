module Sufia::Import
  # Imports a Sufia 6.0-exported Collection into a Sufia PCDM Collection
  class CollectionTranslator
    def initialize(settings)
      @collection_builder = CollectionBuilder.new(settings)
    end

    # loop through the files found in import_dir and map each Collection
    # @param import_dir a directory containing export files, e.g.: collection_[id].json
    # @return list of imported files
    def import(import_dir, filename_prefix)
      filename_prefix ||= "collection_"
      raise "No such directory: '#{import_dir}'" unless Dir.exist?(import_dir)
      # get filenames
      files = Dir.glob(File.join(import_dir, '*')).select { |f| exported_json?(f, filename_prefix) }
      files.each { |f| import_file(f) }
    end

    private

      def import_file(filename)
        Rails.logger.debug "Importing #{File.basename(filename)}"
        file_str = File.read(filename)
        json = JSON.parse(file_str)
        collection = @collection_builder.build(json)
        collection.save
      end

      def exported_json?(f, filename_prefix)
        File.file?(f) &&
          File.extname(f) == '.json' &&
          File.basename(f).start_with?(filename_prefix)
      end
  end
end
