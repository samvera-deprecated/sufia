require 'datastreams/paranoid_rights_datastream'
module Sufia
  module GenericFile
    module Permissions
      extend ActiveSupport::Concern
      #we're overriding the permissions= method which is in RightsMetadata
      include Hydra::ModelMixins::RightsMetadata
      included do
        has_metadata :name => "rightsMetadata", :type => ParanoidRightsDatastream
        validate :paranoid_permissions
      end

      def set_visibility(visibility)
        # only set explicit permissions
        case visibility
        when "open"
          self.datastreams["rightsMetadata"].permissions({:group=>"public"}, "read")
        when "psu"
          self.datastreams["rightsMetadata"].permissions({:group=>"registered"}, "read")
          self.datastreams["rightsMetadata"].permissions({:group=>"public"}, "none")
        when "restricted" 
          self.datastreams["rightsMetadata"].permissions({:group=>"registered"}, "none")
          self.datastreams["rightsMetadata"].permissions({:group=>"public"}, "none")
        end
      end


      def paranoid_permissions
        # let the rightsMetadata ds make this determination
        # - the object instance is passed in for easier access to the props ds
        rightsMetadata.validate(self)
      end

      ## Updates those permissions that are provided to it. Does not replace any permissions unless they are provided
      def permissions=(params)
        perm_hash = permission_hash
        params[:new_user_name].each { |name, access| perm_hash['person'][name] = access } if params[:new_user_name].present?
        params[:new_group_name].each { |name, access| perm_hash['group'][name] = access } if params[:new_group_name].present?

        params[:user].each { |name, access| perm_hash['person'][name] = access} if params[:user]
        params[:group].each { |name, access| perm_hash['group'][name] = access} if params[:group]
        rightsMetadata.update_permissions(perm_hash)
      end

      private

      def permission_hash
        old_perms = self.permissions
        user_perms =  {}
        old_perms.select{|r| r[:type] == 'user'}.each do |r|
          user_perms[r[:name]] = r[:access]
        end
        user_perms
        group_perms =  {}
        old_perms.select{|r| r[:type] == 'group'}.each do |r|
          group_perms[r[:name]] = r[:access]
        end
        {'person'=>user_perms, 'group'=>group_perms}
      end


    end
  end
end
