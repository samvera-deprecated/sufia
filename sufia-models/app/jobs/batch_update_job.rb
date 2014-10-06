class BatchUpdateJob
  include Hydra::PermissionsQuery
  include Sufia::Messages

  def queue_name
    :batch_update
  end

  attr_accessor :login, :title, :file_attributes, :batch_id, :visibility, :saved, :denied

  def initialize(login, params)
    self.login = login
    self.title = params[:title]
    self.file_attributes = params[:generic_file]
    self.visibility = params[:visibility]
    self.batch_id = params[:id]
    self.saved = []
    self.denied = []
  end

  def run
    batch = Batch.find_or_create(self.batch_id)
    user = User.find_by_user_key(self.login)

    batch.generic_files.each do |gf|
      update_file(gf, user)
    end
    batch.update_attributes({status:["Complete"]})
    if denied.empty?
      send_user_success_message(user, batch) unless saved.empty?
    else
      send_user_failure_message(user, batch)
    end
  end

  def update_file(gf, user)
    unless user.can? :edit, gf
      ActiveFedora::Base.logger.error "User #{user.user_key} DENIED access to #{gf.pid}!"
      denied << gf
      return
    end
    gf.title = title[gf.pid] if title[gf.pid] rescue gf.label
    gf.attributes=file_attributes
    gf.visibility= visibility

    save_tries = 0
    begin
      gf.save!
    rescue RSolr::Error::Http => error
      save_tries += 1
      ActiveFedora::Base.logger.warn "BatchUpdateJob caught RSOLR error on #{gf.pid}: #{error.inspect}"
      # fail for good if the tries is greater than 3
      raise error if save_tries >=3
      sleep 0.01
      retry
    end #
    Sufia.queue.push(ContentUpdateEventJob.new(gf.pid, login))
    saved << gf
  end

  def send_user_success_message user, batch
    message = saved.count > 1 ? multiple_success(batch.noid, saved) : single_success(batch.noid, saved.first)
    User.batchuser.send_message(user, message, success_subject, sanitize_text = false)
  end

  def send_user_failure_message user, batch
    message = denied.count > 1 ? multiple_failure(batch.noid, denied) : single_failure(batch.noid, denied.first)
    User.batchuser.send_message(user, message, failure_subject, sanitize_text = false)
  end
  
end
