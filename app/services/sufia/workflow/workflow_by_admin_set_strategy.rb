module Sufia
  module Workflow
    class WorkflowByAdminSetStrategy
      attr_reader :admin_set_id
      def initialize(work, attributes)
        @work = work
        @admin_set_id = attributes[:admin_set_id] unless attributes[:admin_set_id].nil?
      end

      # @return [String] The name of the workflow by admin_set to use
      def work_name
        @work.model_name.singular
      end
    end
  end
end
