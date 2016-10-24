module Sufia::Import
  # Imports a Sufia 6.0-exported GenericFile into a Sufia PCDM GernericWork and FileSet
  class GenericFileTranslator
    # @param Hash settings needed to pass through to builder
    #        @attr sufia6_user      - User name for accessing the sufia 6 fedora
    #        @attr sufia6_password  - Password for accessing the sufia 6 fedora
    #        @attr import_binary    - (default true) Import the binary content from fedora
    def initialize(settings)
      # TODO: work builder doesn't need settings; just file builder
      @work_builder = WorkBuilder.new(settings)
      @file_set_builder = FileSetBuilder.new(settings)
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
