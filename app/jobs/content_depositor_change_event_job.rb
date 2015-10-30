# A specific job to log a file deposit change to a user's activity stream
#
# This is a bit wierd becuase the job performs the depositor transfer along with logging the job
#
# @attr [String] id identifier of the file to be transfered
# @attr [String] login the user key of the user the file is being transfered to.
# @attr [Boolean] reset (false) should the access controls be reset. This means revoking edit access from the depositor
class ContentDepositorChangeEventJob < ContentEventJob
  def queue_name
    :proxy_deposit
  end

  attr_accessor :id, :login, :reset

  # @param [String] id identifier of the file to be transfered
  # @param [String] login the user key of the user the file is being transfered to.
  # @param [Boolean] reset (false) should the access controls be reset. This means revoking edit access from the depositor
  def initialize(id, login, reset = false)
    super(id, login)
    self.id = id
    self.login = login
    self.reset = reset
  end

  def run
    super

    # log the event to the proxy depositor's profile
    proxy_depositor = ::User.find_by_user_key(generic_file.proxy_depositor)
    proxy_depositor.log_profile_event(event)
  end

  def action
    "User #{link_to_profile generic_file.proxy_depositor} has transferred #{link_to generic_file.title.first, Sufia::Engine.routes.url_helpers.generic_file_path(generic_file)} to user #{link_to_profile login}"
  end

  # overriding default to load from fedora and change the depositor
  def generic_file
    # TODO: This should be in its own job, not this event job
    @generic_file ||= begin
      file = ::GenericFile.find(id)
      file.proxy_depositor = file.depositor
      file.clear_permissions! if reset
      file.apply_depositor_metadata(login)
      file.save!
      file
    end
  end

  # overriding default to log the event to the depositor instead of their profile
  def log_user_event
    depositor.log_event(event)
  end
end
