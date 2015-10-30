# A generic job for sending events about a generic files to a user and their followers.
#
# @attr [String] generic_file_id  the id of the file the event is specified for
#
class ContentEventJob < EventJob
  attr_accessor :generic_file_id

  def initialize(generic_file_id, depositor_id)
    super(depositor_id)
    @generic_file_id = generic_file_id
  end

  def run
    super

    log_generic_file_event
  end

  def generic_file
    @generic_file ||= GenericFile.load_instance_from_solr(generic_file_id)
  end

  # Log the event to the GF's stream
  def log_generic_file_event
    generic_file.log_event(event) unless generic_file.nil?
  end

  # override to check file permissions before logging to followers
  def log_to_followers
    depositor.followers.select { |user| user.can?(:read, generic_file) }.each do |follower|
      follower.log_event(event)
    end
  end

  # log the event to the users profile stream
  def log_user_event
    depositor.log_profile_event(event)
  end
end
