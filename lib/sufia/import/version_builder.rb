module Sufia::Import
  # Build all the versions of a file and add it to a file set
  class VersionBuilder
    # build versions based on the input
    #
    # @param file_set FileSet that will be modifed to include versions
    # @param Array[hash] generic_file_versions, each with the keys below
    #   @option :uri Link to content in Sufia 6 repository
    #   @option :label Version label
    #   @option :created date the version was created
    #
    def build(file_set, generic_file_versions)
      sorted_versions = generic_file_versions.sort_by { |ver| ver[:created] }
      sorted_versions.each_with_index do |gf_version, index|
        filename_on_disk = create(file_set, gf_version)

        # characterize the current version
        characterize(file_set, filename_on_disk) if index == (sorted_versions.count - 1)

        File.delete(filename_on_disk)
      end
    end

    private

      def create(file_set, version)
        filename_on_disk = File.join Dir.tmpdir, "#{file_set.id}_#{version[:label]}"
        Rails.logger.debug "[IMPORT] Downloading #{version} to #{filename_on_disk}"
        File.open(filename_on_disk, 'wb') do |file_to_upload|
          source_uri = sufia6_version_open_uri(version[:uri])
          file_to_upload.write source_uri.read
        end

        # ...upload it...
        File.open(filename_on_disk, 'rb') do |file_to_upload|
          Sufia::Import::AddVersionToFileSet.call(file_set, file_to_upload, :original_file, version[:created])
        end

        filename_on_disk
      end

      def sufia6_version_open_uri(content_uri)
        open(content_uri, http_basic_authentication: [sufia6_user, sufia6_password])
      end

      def characterize(file_set, filename_on_disk)
        CharacterizeJob.perform_now(file_set, file_set.original_file.id, filename_on_disk)
      end

      def sufia6_user
        Rails.configuration.fedora_sufia6_user
      rescue NoMethodError
        raise "Please configure fedora_sufia6_user in config/application.rb"
      end

      def sufia6_password
        Rails.configuration.fedora_sufia6_password
      rescue NoMethodError
        raise "Please configure fedora_sufia6_password in config/application.rb"
      end
  end
end
