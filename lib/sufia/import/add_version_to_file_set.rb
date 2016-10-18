module Sufia
  module Import
    # Follow the Hydra::Works:AddFileToFileSet to add a new version and
    # set the date_created attribute before the version is minted
    class AddVersionToFileSet
      # Adds a version to the file_set with the date_created
      # @param [Hydra::PCDM::FileSet] file_set the file will be added to
      # @param [IO,File,Rack::Multipart::UploadedFile, #read] object that will be the contents. If file responds to :mime_type, :content_type, :original_name, or :original_filename, those will be called to provide metadata.
      # @param [RDF::URI or String] type URI for the RDF.type that identifies the file's role within the file_set
      # @param [DateTime string] date_created date the version was previously created
      def self.call(file_set, file, type, date_created)
        raise ArgumentError, 'supplied object must be a file set' unless file_set.file_set?
        raise ArgumentError, 'supplied file must respond to read' unless file.respond_to? :read

        # TODO: required as a workaround for https://github.com/projecthydra/active_fedora/pull/858
        file_set.save unless file_set.persisted?

        status = Sufia::Import::VersioningUpdater.new(file_set, type, true, date_created).update(file)
        status ? file_set : false
      end
    end

    class VersioningUpdater < Hydra::Works::AddFileToFileSet::VersioningUpdater
      attr_reader :date_created
      def initialize(file_set, type, update_existing, date_created)
        super(file_set, type, update_existing)
        @date_created = date_created
      end

      def attach_attributes(file)
        super(file)
        current_file.date_created = date_created
      end
    end
  end
end
