module Sufia
  module Workflow
    class WorkflowByAdminSetStrategy
      def initialize(work, _attributes)
        @work = work
        unless _attributes[:admin_set_id].nil?
            @admin_set_id = _attributes[:admin_set_id]
        end
      end

      # @return [String] The name of the workflow by admin_set to use
      def work_name
        @work.model_name.singular
      end

      def admin_set_id
        @admin_set_id
      end
    end
  end
end
