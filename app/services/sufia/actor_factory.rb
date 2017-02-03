module Sufia
  class ActorFactory < CurationConcerns::Actors::ActorFactory
    def self.stack_actors(curation_concern)
      [OptimisticLockValidator,
       CreateWithRemoteFilesActor,
       CreateWithFilesActor,
       CurationConcerns::Actors::AddToCollectionActor,
       CurationConcerns::Actors::AddToWorkActor,
       CurationConcerns::Actors::AssignRepresentativeActor,
       CurationConcerns::Actors::AttachFilesActor,
       CurationConcerns::Actors::ApplyOrderActor,
       InterpretVisibilityActor,
       DefaultAdminSetActor,
       CurationConcerns::Actors::InitializeWorkflowActor,
       ApplyPermissionTemplateActor,
       model_actor(curation_concern)]
    end
  end
end
