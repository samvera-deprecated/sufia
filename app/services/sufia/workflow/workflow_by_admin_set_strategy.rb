module Sufia
  module Workflow
    class WorkflowByAdminSetStrategy
      attr_reader :admin_set_id
      def initialize(work, attributes)
        @work = work
        @admin_set_id = attributes[:admin_set_id]
      end

      # @return [String] The name of the workflow by admin_set to use
      def workflow_name
        #@work.model_name.singular
        @admin_set_id ||= 'default'
      end
    end
  end
end
