class ContentDepositEventJob < EventJob
  def run
    gf = GenericFile.find(generic_file_id)
    action = "User #{link_to_profile depositor_id} has deposited #{link_to gf.title.first, Sufia::Engine.routes.url_helpers.generic_file_path(gf.noid)}"
    timestamp = Time.now.to_i
    depositor = User.find_by_user_key(depositor_id)
    # Create the event
    event = depositor.create_event(action, timestamp)
    # Log the event to the depositor's profile stream
    depositor.log_profile_event(event)
    # Log the event to the GF's stream
    gf.log_event(event)
    # Fan out the event to all followers who have access
    depositor.followers.select { |user| user.can? :read, gf }.each do |follower|
      follower.log_event(event)
    end
  end
end
