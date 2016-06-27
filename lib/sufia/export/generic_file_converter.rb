module Sufia
  module Export
    # Convert a GenericFile including metadata, permissions and version metadata into a PORO
    # so that the metadata can be exported in json format using to_json
    #
    class GenericFileConverter < Converter
      # Create an instance of a GenericFile converter containing all the metadata for json export
      #
      # @param [GenericFile] generc_file file to be converted for export
      def initialize(generc_file)
        @id = generc_file.id
        @label = generc_file.label
        @depositor = generc_file.depositor
        @arkivo_checksum = generc_file.arkivo_checksum
        @relative_path = generc_file.relative_path
        @import_url = generc_file.import_url
        @resource_type = generc_file.resource_type
        @title = generc_file.title
        @creator = generc_file.creator
        @contributor = generc_file.contributor
        @description = generc_file.description
        @tag = generc_file.tag
        @rights = generc_file.rights
        @publisher = generc_file.publisher
        @date_created = generc_file.date_created
        @date_uploaded = generc_file.date_uploaded
        @date_modified = generc_file.date_modified
        @subject = generc_file.subject
        @language = generc_file.language
        @identifier = generc_file.identifier
        @based_near = generc_file.based_near
        @related_url = generc_file.related_url
        @bibliographic_citation = generc_file.bibliographic_citation
        @source = generc_file.source
        @batch_id = generc_file.batch.id if generc_file.batch
        @visibility = generc_file.visibility
        @versions = versions(generc_file)
        @permissions = permissions(generc_file)
      end

      private

        def versions(gf)
          return [] unless gf.content.has_versions?
          Sufia::Export::VersionGraphConverter.new(gf.content.versions).versions
        end
    end
  end
end
