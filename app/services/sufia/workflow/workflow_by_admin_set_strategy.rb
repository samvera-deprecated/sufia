module Sufia
  module Workflow
    class WorkflowByAdminSetStrategy
      def initialize(work, attributes)
        @work = work
        @admin_set_id = attributes.fetch(:admin_set_id, 'default')
      end

      # @return [String] The name of the workflow by admin_set to use
      def workflow_name
        @admin_set_id
      end
    end
  end
end
