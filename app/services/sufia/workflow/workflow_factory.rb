module Sufia
  module Workflow
    class WorkflowFactory < CurationConcerns::Workflow::WorkflowFactory
      self.workflow_strategy = WorkflowByAdminSetStrategy
    end
  end
end
