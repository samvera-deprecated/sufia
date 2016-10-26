module Sufia::Import
  # Imports a Sufia 6.0-exported GenericFile into a Sufia PCDM GernericWork and FileSet
  class GenericFileTranslator
    # @param Hash settings
    #   @attr import_binary    - (default true) Import the binary content from sufia6 fedora instance
    #     If true, sufia6_user and sufia6_password must be set in the appropriate sections of fedora.yml
    def initialize(settings)
      import_binary = settings.fetch(:import_binary, true)
      @work_builder = WorkBuilder.new
      @file_set_builder = FileSetBuilder.new(import_binary)
    end

    # loop through the files found in import_dir and map each GenericFile to a Sufia.primary_work and FileSet
    # @param import_dir a directory containing export files, e.g.: generic_file_[id].json
    # @return list of imported files
    def import(import_dir, filename_prefix)
      filename_prefix ||= "generic_file_"
      raise "No such directory: '#{import_dir}'" unless Dir.exist?(import_dir)
      # get filenames
      files = Dir.glob(File.join(import_dir, '*')).select { |f| exported_gf?(f, filename_prefix) }
      files.each { |f| import_file(f) }
    end

    private

      def import_file(filename)
        Rails.logger.debug "Importing #{File.basename(filename)}"
        file_str = File.read(filename)
        json = JSON.parse(file_str)
        fileset = @file_set_builder.build(json)
        work = @work_builder.build(json)
        link(work, fileset)
      end

      def link(work, fileset)
        work.ordered_members << fileset
        work.thumbnail_id = fileset.id
        work.representative_id = fileset.id
        work.save
      end

      def exported_gf?(f, filename_prefix)
        File.file?(f) &&
          File.extname(f) == '.json' &&
          File.basename(f).start_with?(filename_prefix)
      end
  end
end
