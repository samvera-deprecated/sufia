module Sufia
  module Import
    # Base class to hold shared logic
    class Translator
      # @param Hash settings
      #   @attr import_dir string (default 'tmp/import') a directory containing export files
      #   @attr filename_prefix (default varies by implementor) string common beginning of all files to be imported
      def initialize(settings)
        @import_dir = settings.fetch(:import_dir, "tmp/import")
        @filename_prefix = settings.fetch(:filename_prefix, default_prefix)
      end

      # loop through the files found in import_dir and map each to its corresponding object/s
      def import
        raise "No such directory: '#{@import_dir}'" unless Dir.exist?(@import_dir)
        # get filenames
        files = Dir.glob(File.join(@import_dir, '*')).select { |f| exported_json?(f, @filename_prefix) }
        files.each do |file|
          begin
            import_file(file)
          rescue RuntimeError => e
            Sufia::Import::Log.error("\"#{file}\",\"#{e.message}\"\n")
          end
        end
      end

      protected

        def import_file(filename)
          Rails.logger.debug "Importing #{File.basename(filename)}"
          file_str = File.read(filename)
          json = JSON.parse(file_str)
          raise "Id exists in Fedora before import: #{json['id']}" if ActiveFedora::Base.exists?(json["id"])
          build_from_json(json)
        end

        def default_prefix
          raise "Please override"
        end

        def build_from_json(_json)
          raise "Please override"
        end

        def exported_json?(f, filename_prefix)
          File.file?(f) &&
            File.extname(f) == '.json' &&
            File.basename(f).start_with?(filename_prefix)
        end
    end
  end
end
