# Builder for generating a File set incluing permissions and versions
#
module Sufia::Import
  class FileSetBuilder < Builder
    attr_reader :file_set, :permission_builder, :version_builder

    # @param settings see Sufia::Import::Builder for settings
    def initialize(settings)
      super
      @file_set = FileSet.new
      @permission_builder = PermissionBuilder.new(settings, file_set)
      @version_builder = VersionBuilder.new(settings, file_set)
    end

    # Build a FileSet from GenericFile metadata
    #
    # @param OpenStruct generic_file_metadata metadata from the generic_file in OpenStruct format
    #    <OpenStruct id="44558d49x", label="my label", depositor="cam156@psu.edu", arkivo_checksum="arkivo checksum",
    #                relative_path="relative path", import_url="import url", resource_type=["resource type"],
    #                title=["My Great File"], creator=["cam156@psu.edu"], contributor=["contributor1", "contribnutor2"],
    #                description=["description of the file"], tag=["tag1", "tag2"], rights=["Attribution 3.0"],
    #                publisher=["publisher joe"], date_created=["a long time ago"], date_uploaded="2015-09-28T20:00:14.243+00:00",
    #                date_modified="2015-10-28T20:00:14.243+00:00", subject=["subject 1", "subject 2"], language=["WA Language WA"],
    #                identifier=["You ID ME"], based_near=["Kalamazoo"], related_url=["abc123.org"], bibliographic_citation=["cite me"],
    #                source=["source of me"], batch_id="qn59q409q", visibility="restricted",
    #                versions=[#<OpenStruct uri="http://127.0.0.1:8983/fedora/rest/dev/44/55/8d/49/44558d49x/content/fcr:versions/version1",
    #                          created="2016-09-28T20:00:14.658Z", label="version1">, ...],
    #                permissions=[#<OpenStruct id="b5911dfd-07b1-43ab-b11d-1bc0534d874c", agent="http://projecthydra.org/ns/auth/person#cam156@psu.edu", mode="http://www.w3.org/ns/auth/acl#Write", access_to="44558d49x">...]>
    def build(generic_file_metadata)
      file_set.title << generic_file_metadata.title
      # Where did the filename property go?
      # file_set.filename = generic_file_metadata.filename
      file_set.label = generic_file_metadata.label
      file_set.date_uploaded = generic_file_metadata.date_uploaded
      file_set.date_modified = generic_file_metadata.date_modified
      file_set.apply_depositor_metadata(generic_file_metadata.depositor)
      permission_builder.build(generic_file_metadata.permissions)

      # File
      version_builder.build(generic_file_metadata.versions) if import_binary

      file_set
    end
  end
end
