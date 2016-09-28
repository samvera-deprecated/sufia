module Sufia::Import
  # Build all the versions of a file and add it to a file set
  #
  #
  class VersionBuilder < Builder
    attr_reader :file_set

    # @param settings see Sufia::Import::Builder for settings
    # @param file_set FileSet that will be modifed to include versions
    def initialize(settings, file_set)
      super(settings)
      @file_set = file_set
    end

    # build versions based on the input
    #
    # @param Array[OpenStruct] generic_file_versions
    #     Each item is expected to contain uri, label, and created
    #       uri     - Link to content in Sufia 6 repository
    #       label   - Version label
    #       created - date the version was created
    #
    def build(generic_file_versions)
      sorted_versions = generic_file_versions.sort_by(&:created)
      sorted_versions.each_with_index do |gf_version, index|
        filename_on_disk = create(gf_version)

        # characterize the current version
        characterize(filename_on_disk) if index == (sorted_versions.count - 1)

        File.delete(filename_on_disk)
      end
    end

    private

      def create(version)
        filename_on_disk = File.join Dir.tmpdir, "#{file_set.id}_#{version.label}"
        Rails.logger.debug "[IMPORT] Downloading #{version} to #{filename_on_disk}"
        File.open(filename_on_disk, 'wb') do |file_to_upload|
          source_uri = sufia6_version_open_uri(version.uri)
          file_to_upload.write source_uri.read
        end

        # ...upload it...
        File.open(filename_on_disk, 'rb') do |file_to_upload|
          Hydra::Works::UploadFileToFileSet.call(file_set, file_to_upload)
        end
        filename_on_disk
      end

      def sufia6_version_open_uri(content_uri)
        open(content_uri, http_basic_authentication: [sufia6_user, sufia6_password])
      end

      def characterize(filename_on_disk)
        CharacterizeJob.perform_now(file_set, file_set.original_file.id, filename_on_disk)
      end
  end
end
