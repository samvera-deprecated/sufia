module Sufia::Import
  # Imports a Sufia 6.0-exported GenericFile into a Sufia PCDM GernericWork and FileSet
  class GenericFileTranslator < Translator
    # @param Hash settings (see super for more)
    #   @attr import_binary    - (default true) Import the binary content from sufia6 fedora instance
    #     If true, sufia6_user and sufia6_password must be set in the appropriate sections of fedora.yml
    def initialize(settings)
      super
      import_binary = settings.fetch(:import_binary, true)
      @work_builder = WorkBuilder.new
      @file_set_builder = FileSetBuilder.new(import_binary)
    end

    private

      def build_from_json(json)
        fileset = @file_set_builder.build(json)
        work = @work_builder.build(json)
        link(work, fileset)
      end

      def default_prefix
        "generic_file_"
      end

      def link(work, fileset)
        work.ordered_members << fileset
        work.thumbnail_id = fileset.id
        work.representative_id = fileset.id
        work.save
      end
  end
end
