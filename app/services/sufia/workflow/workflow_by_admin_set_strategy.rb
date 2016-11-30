module Sufia
  module Workflow
    class WorkflowByAdminSetStrategy
      def initialize(_work, attributes)
        @admin_set_id = attributes[:admin_set_id] if attributes[:admin_set_id].present?
      end

      # @return [String] The name of the workflow by admin_set to use
      def workflow_name
        return 'default' unless @admin_set_id
        Sufia::PermissionTemplate.find_by!(admin_set_id: @admin_set_id).workflow_name
      end
    end
  end
end
