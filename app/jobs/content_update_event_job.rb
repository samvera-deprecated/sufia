# A specific job to log a file content update to a user's activity stream
class ContentUpdateEventJob < ContentEventJob
  def action
    @action ||= "User #{link_to_profile depositor_id} has updated #{link_to generic_file.title.first, Sufia::Engine.routes.url_helpers.generic_file_path(generic_file)}"
  end
end
