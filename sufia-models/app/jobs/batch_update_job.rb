# Resque job that updates files uploaded via the BatchController
class BatchUpdateJob
  include Hydra::PermissionsQuery
  include Sufia::Messages

  def queue_name
    :batch_update
  end

  attr_reader :login, :batch_id, :title, :file_attributes, :visibility
  attr_writer :saved, :denied

  # Called from BatchController
  # @param [String] login of the current user
  # @param [String] batch_id for the Batch object containing the files
  # @param [Hash] title contains the filename of each file
  # @param [Hash] file_attributes applied to every file in the batch
  # @param [String] visibility
  def initialize(login, batch_id, title, file_attributes, visibility)
    @login = login
    @batch_id = batch_id
    @title = title || {}
    @file_attributes = file_attributes
    @visibility = visibility
  end

  def run
    batch.generic_files.each { |gf| update_file(gf) }
    batch.update(status: ["Complete"])
    send_user_message
  end

  # Updates the metadata for one file in the batch. Override this method if you wish to perform
  # additional operations to these files.
  # @param [GenericFile] gf
  def apply_metadata(gf)
    gf.title = title[gf.id] if title[gf.id]
    gf.attributes = file_attributes
    gf.visibility = visibility
  end

  # Queues jobs to run on each file. By default, this includes ContentUpdateEventJob, but
  # can be augmented with additional custom jobs
  # @param [GenericFile] gf
  def queue_additional_jobs(gf)
    Sufia.queue.push(ContentUpdateEventJob.new(gf.id, login))
    Sufia.queue.push(ResolrizeGenericFileJob.new(gf.id)) unless Sufia.config.collection_facet.nil?
  end

  def send_user_success_message
    message = saved.count > 1 ? multiple_success(batch.id, saved) : single_success(batch.id, saved.first)
    User.batchuser.send_message(user, message, success_subject, false)
  end

  def send_user_failure_message
    message = denied.count > 1 ? multiple_failure(batch.id, denied) : single_failure(batch.id, denied.first)
    User.batchuser.send_message(user, message, failure_subject, false)
  end

  private

    def update_file(gf, you = nil)
      you ||= user
      unless you.can? :edit, gf
        ActiveFedora::Base.logger.error "User #{you.user_key} DENIED access to #{gf.id}!"
        denied << gf
        return
      end

      apply_metadata(gf)

      save_tries = 0
      begin
        gf.save!
      rescue RSolr::Error::Http => error
        save_tries += 1
        ActiveFedora::Base.logger.warn "BatchUpdateJob caught RSOLR error on #{gf.id}: #{error.inspect}"
        # fail for good if the tries is greater than 3
        raise error if save_tries >= 3
        sleep 0.01
        retry
      end
      queue_additional_jobs(gf)
      saved << gf
    end

    def send_user_message
      if denied.empty?
        send_user_success_message unless saved.empty?
      else
        send_user_failure_message
      end
    end

    def batch
      @batch ||= Batch.find_or_create(batch_id)
    end

    def user
      @user ||= User.find_by_user_key(login)
    end

    def saved
      @saved ||= []
    end

    def denied
      @denied ||= []
    end
end
