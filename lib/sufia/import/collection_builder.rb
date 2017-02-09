# Builder for generating a collection including permissions
#
module Sufia::Import
  class CollectionBuilder
    attr_reader :permission_builder

    def initialize
      @permission_builder = PermissionBuilder.new
    end

    # Build a Collection from json data
    #
    # @param hash json metadata from the collection, e.g.:
    #    { "id": "2v23vt57t", "title": "Fantasy", "description": "Magic and power", "creator": [ "Arthur" ],
    #            "depositor": "depositor@example.com", "members": [ "qr46r0963" ],
    #            "permissions": [ { "id": "2a9205fa-ad70-4888-9441-39bfba6fc95e",
    #                "agent": "http://projecthydra.org/ns/auth/person#depositor@example.com", "mode": "http://www.w3.org/ns/auth/acl#Write",
    #                "access_to": "2v23vt57t" } ] }
    def build(json)
      collection = Collection.new
      data = json.deep_symbolize_keys
      members = get_members(data.delete(:members))
      # TODO: a couple fields exported as single-valued but are expected to be multi
      #   difference in data models between versions? or problem with export script?
      data[:title] = Array(data[:title])
      data[:description] = Array(data[:description])
      collection.apply_depositor_metadata(data.delete(:depositor))
      permission_builder.build(collection, data.delete(:permissions))
      collection.update_attributes(data)
      members.each { |w| collection.members << w }

      collection
    end

    def get_members(data)
      members = []
      missing_files = []
      data.each do |id|
        begin
          members << Sufia.primary_work_type.find(id)
        rescue ActiveFedora::ObjectNotFoundError
          missing_files << id
        end
      end
      if missing_files.count > 0
        message = "Error getting members #{missing_files.join(', ')}."
        message += "  #{Sufia.primary_work_type} must be imported before Collections" if missing_files.count == data.count
        raise message
      end
      members
    end
  end
end
