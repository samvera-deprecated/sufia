# Builder for generating a work incluing permissions
#
module Sufia::Import
  class WorkBuilder < Builder
    attr_reader :work, :permission_builder

    # @param settings see Sufia::Import::Builder for settings
    def initialize(settings)
      super
      @work = Sufia.primary_work_type.new
      @permission_builder = PermissionBuilder.new(settings, work)
    end

    # Build a Work from GenericFile metadata
    #
    # @param hash gf_metadata metadata from the generic_file, e.g.:
    #    { id: "44558d49x", label: "my label", depositor: "cam156@psu.edu", arkivo_checksum: "arkivo checksum",
    #                relative_path: "relative path", import_url: "import url", resource_type: ["resource type"],
    #                title: ["My Great File"], creator: ["cam156@psu.edu"], contributor: ["contributor1", "contribnutor2"],
    #                description: ["description of the file"], tag: ["tag1", "tag2"], rights: ["Attribution 3.0"],
    #                publisher: ["publisher joe"], date_created: ["a long time ago"], date_uploaded: "2015-09-28T20:00:14.243+00:00",
    #                date_modified: "2015-10-28T20:00:14.243+00:00", subject: ["subject 1", "subject 2"], language: ["WA Language WA"],
    #                identifier: ["You ID ME"], based_near: ["Kalamazoo"], related_url: ["abc123.org"], bibliographic_citation: ["cite me"],
    #                source: ["source of me"], batch_id: "qn59q409q", visibility: "restricted",
    #                versions: [],
    #                permissions: [ { id: "b5911dfd-07b1-43ab-b11d-1bc0534d874c", agent: "http://projecthydra.org/ns/auth/person#cam156@psu.edu", mode: "http://www.w3.org/ns/auth/acl#Write", access_to: "44558d49x" } ] }
    def build(gf_metadata)
      data = gf_metadata.deep_symbolize_keys
      data.delete(:batch_id) # This attribute was removed in sufia 7
      data.delete(:versions) # works don't have versions; these are used in file set builder
      work.keyword << data.delete(:tag)
      work.apply_depositor_metadata(data.delete(:depositor))
      permission_builder.build(data.delete(:permissions))
      work.update_attributes(data)

      work
    end
  end
end