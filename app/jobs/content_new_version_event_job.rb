# A specific job to log a file new version to a user's activity stream
class ContentNewVersionEventJob < ContentEventJob
  def action
    @action ||= "User #{link_to_profile depositor_id} has added a new version of #{link_to generic_file.title.first, Sufia::Engine.routes.url_helpers.generic_file_path(generic_file)}"
  end
end
