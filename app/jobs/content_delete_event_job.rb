# A specific job to log a file deletion to a user's activity stream
#
# @attr_reader deleted_file_id The id of the file that has been deleted by the user
class ContentDeleteEventJob < EventJob
  attr_reader :deleted_file_id

  def initialize(deleted_file_id, depositor_id)
    super(depositor_id)
    @deleted_file_id = deleted_file_id
  end

  def action
    @action ||= "User #{link_to_profile depositor_id} has deleted file '#{deleted_file_id}'"
  end

  # override to log the event to the users profile stream instead of the user's stream
  def log_user_event
    depositor.log_profile_event(event)
  end
end
