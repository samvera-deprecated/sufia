# Builder for generating a File set incluing permissions and versions
#
module Sufia::Import
  class FileSetBuilder
    attr_reader :import_binary

    # @param import_binary boolean indicating whether to import the binary from sufia6 fedora instance
    #     If true, fedora_sufia6_user and fedora_sufia6_password must be set in config/application.rb
    def initialize(import_binary)
      @import_binary = import_binary
    end

    # Build a FileSet from GenericFile metadata
    #
    # @param hash generic_file_metadata, e.g.:
    #    { id: "44558d49x", label: "my label", depositor: "cam156@psu.edu", arkivo_checksum: "arkivo checksum",
    #                relative_path: "relative path", import_url: "import url", resource_type: ["resource type"],
    #                title: ["My Great File"], creator: ["cam156@psu.edu"], contributor: ["contributor1", "contribnutor2"],
    #                description: ["description of the file"], tag: ["tag1", "tag2"], rights: ["Attribution 3.0"],
    #                publisher: ["publisher joe"], date_created: ["a long time ago"], date_uploaded: "2015-09-28T20:00:14.243+00:00",
    #                date_modified: "2015-10-28T20:00:14.243+00:00", subject: ["subject 1", "subject 2"], language: ["WA Language WA"],
    #                identifier: ["You ID ME"], based_near: ["Kalamazoo"], related_url: ["abc123.org"], bibliographic_citation: ["cite me"],
    #                source: ["source of me"], batch_id: "qn59q409q", visibility: "restricted",
    #                versions: [ { uri: "http://127.0.0.1:8983/fedora/rest/dev/44/55/8d/49/44558d49x/content/fcr:versions/version1",
    #                          created: "2016-09-28T20:00:14.658Z", label: "version1" }, ...],
    #                permissions: [ { id: "b5911dfd-07b1-43ab-b11d-1bc0534d874c", agent: "http://projecthydra.org/ns/auth/person#cam156@psu.edu", mode: "http://www.w3.org/ns/auth/acl#Write", access_to: "44558d49x" }, ...] }
    def build(gf_metadata)
      file_set = FileSet.new
      permission_builder = PermissionBuilder.new
      version_builder = VersionBuilder.new
      data = gf_metadata.deep_symbolize_keys
      # TODO: Where did the filename property go?
      # file_set.filename = data.filename
      file_set.title << data[:title]
      file_set.label = data[:label]
      file_set.date_uploaded = data[:date_uploaded]
      file_set.date_modified = data[:date_modified]
      file_set.apply_depositor_metadata(data[:depositor])
      permission_builder.build(file_set, data[:permissions])
      # bring over the File
      version_builder.build(file_set, data[:versions]) if @import_binary

      file_set
    end
  end
end
