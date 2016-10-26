# Create permissions on a Work or FileSet
module Sufia::Import
  class PermissionBuilder
    attr_reader :object

    # @param PCDMObject object   Object for the permissions to be applied to
    #
    def initialize(object)
      @object = object
    end

    # Build permissions on a FileSet or a work based on the metadata from GenericFile
    #
    #  @param Array[hash] generic_file_perms An array of hashes with the below keys
    #  @option :agent    - Agent that has permisisons; example: "http://projecthydra.org/ns/auth/person#user1@example.com"
    #  @option :mode     - access acl; example: "http://www.w3.org/ns/auth/acl#Write"
    #  @option :acces_to - not used - Permissions are added to the object passed in the initializer
    #  @option :id       - not used - Id for the permissions is generated
    def build(generic_file_perms)
      generic_file_perms.each do |gf_perm|
        create(gf_perm)
      end
    end

    private

      def create(gf_perm)
        return if permission_exists(gf_perm)
        # agent = http://projecthydra.org/ns/auth/person#cam156@psu.edu"
        agent_parts = gf_perm[:agent].split("/").last.split("#") # e.g. "http://projecthydra.org/ns/auth/person#hjc14"
        type = agent_parts.first
        name = agent_parts.last

        # acess = http://www.w3.org/ns/auth/acl#Write
        access = gf_perm[:mode].split("#").last.downcase # e.g. "http://www.w3.org/ns/auth/acl#Write"
        access = "edit" if access == "write"
        object.permissions.build(name: name, type: type, access: access)
      end

      def permission_exists(gf_perm)
        !object.permissions.to_a.find { |p| p.agent[0] == gf_perm[:agent] && p.mode[0] == gf_perm[:mode] }.nil?
      end
  end
end
