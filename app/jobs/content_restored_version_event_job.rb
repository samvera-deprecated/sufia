# A specific job to log a file restored version to a user's activity stream
class ContentRestoredVersionEventJob < ContentEventJob
  attr_accessor :revision_id

  def initialize(generic_file_id, depositor_id, revision_id)
    super(generic_file_id, depositor_id)
    @revision_id = revision_id
  end

  def action
    @action ||= "User #{link_to_profile depositor_id} has restored a version '#{revision_id}' of #{link_to generic_file.title.first, Sufia::Engine.routes.url_helpers.generic_file_path(generic_file)}"
  end
end
