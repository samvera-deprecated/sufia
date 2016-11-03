module CurationConcerns
  module Workflow
    # Responsible for describing the JSON schema for a Workflow.
    #
    # The `workflows name` defines the name of the Sipity::Workflow.
    # The `workflows actions` defines the actions that can be taken in the given states (e.g. :from_states) by the given :roles.
    # The `workflows actions transition_to` defines the state to which we transition when the action is taken.
    # The `workflows actions notifications` defines the notifications that should be sent when the action is taken.
    #
    # @see Sipity::Workflow
    # @see Sipity::WorkflowAction
    # @see Sipity::WorkflowState
    # @see Sipity::Role
    # @see Sipity::Notification
    # @see Sipity::Method
    # @see ./lib/generators/curation_concerns/work/templates/workflow.json.erb
    WorkflowSchema = Dry::Validation.Schema do
      required(:workflows).each do
        required(:name).filled(:str?) # Sipity::Workflow#name
        optional(:label).filled(:str?) # Sipity::Workflow#label
        optional(:description).filled(:str?) # Sipity::Workflow#description
        required(:actions).each do
          required(:name).filled(:str?) # Sipity::WorkflowAction#name
          required(:from_states).each do
            required(:names) { array? { each(:str?) } } # Sipity::WorkflowState#name
            required(:roles) { array? { each(:str?) } } # Sipity::Role#name
          end
          optional(:transition_to).filled(:str?) # Sipity::WorkflowState#name
          optional(:notifications).each do
            #required(:name).value(format?: /\A[a-z|_]+\Z/i) # Sipity::Notification#name
            required(:name).filled(:str?)
            required(:notification_type).value(included_in?: Sipity::Notification.valid_notification_types)
            required(:to) { array? { each(:str?) } }
            optional(:cc) { array? { each(:str?) } }
            optional(:bcc) { array? { each(:str?) } }
          end
          optional(:methods) { array? { each(:str?) } }
        end
      end
    end
  end
end
