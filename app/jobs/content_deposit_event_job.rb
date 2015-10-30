# A specific job to log a file deposit to a user's activity stream
class ContentDepositEventJob < ContentEventJob
  def action
    "User #{link_to_profile depositor_id} has deposited #{link_to generic_file.title.first, Sufia::Engine.routes.url_helpers.generic_file_path(generic_file)}"
  end
end
