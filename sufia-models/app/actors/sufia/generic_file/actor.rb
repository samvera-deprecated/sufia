module Sufia::GenericFile
  # Actions are decoupled from controller logic so that they may be called from a controller or a background job.
  class Actor
    attr_reader :generic_file, :user

    def initialize(generic_file, user)
      @generic_file = generic_file
      @user = user
    end

    # in order to avoid two saves in a row, create_metadata does not save the file by default.
    # it is typically used in conjunction with create_content, which does do a save.
    # If you want to save when using create_metadata, you can do this:
    #   create_metadata(batch_id) { |gf| gf.save }
    def create_metadata(batch_id)
      generic_file.apply_depositor_metadata(user)
      time_in_utc = DateTime.now.new_offset(0)
      generic_file.date_uploaded = time_in_utc
      generic_file.date_modified = time_in_utc
      generic_file.creator = [user.name]

      if batch_id
        generic_file.batch_id = batch_id
      else
        ActiveFedora::Base.logger.warn "unable to find batch to attach to"
      end
      yield(generic_file) if block_given?
    end

    def create_content(file, file_name, path, mime_type, collection_id = nil)
      generic_file.add_file(file, path: path, original_name: file_name, mime_type: mime_type)
      generic_file.label ||= file_name
      generic_file.title = [generic_file.label] if generic_file.title.blank?
      saved = save_characterize_and_record_committer do
        if Sufia.config.respond_to?(:after_create_content)
          Sufia.config.after_create_content.call(generic_file, user)
        end
      end
      add_file_to_collection(collection_id) if saved
      saved
    end

    def add_file_to_collection(collection_id)
      return if collection_id.nil? || collection_id == "-1"
      collection = Collection.find(collection_id)
      return unless user.can? :edit, collection
      acquire_lock_for(collection_id) do
        collection.add_members [generic_file.id]
        begin
          collection.save
        rescue StandardError => error
          Sufia.config.upload_logger.warn "Sufia::GenericFile::Actor::add_file_to_collection Error adding #{generic_file.title} to collection #{collection.title}. Caught Exception error #{error.inspect}"
          raise error
        end
      end
    end

    def revert_content(revision_id)
      generic_file.content.restore_version(revision_id)
      generic_file.content.create_version
      save_characterize_and_record_committer do
        if Sufia.config.respond_to?(:after_revert_content)
          Sufia.config.after_revert_content.call(generic_file, user, revision_id)
        end
      end
    end

    def update_content(file, path)
      generic_file.add_file(file, path: path, original_name: file.original_filename, mime_type: file.content_type)
      save_characterize_and_record_committer do
        if Sufia.config.respond_to?(:after_update_content)
          Sufia.config.after_update_content.call(generic_file, user)
        end
      end
    end

    def update_metadata(attributes, visibility)
      generic_file.attributes = attributes
      update_visibility(visibility)
      generic_file.date_modified = DateTime.now
      remove_from_feature_works if generic_file.visibility_changed? && !generic_file.public?
      save_and_record_committer do
        if Sufia.config.respond_to?(:after_update_metadata)
          Sufia.config.after_update_metadata.call(generic_file, user)
        end
      end
    end

    def destroy
      generic_file.destroy
      FeaturedWork.where(generic_file_id: generic_file.id).destroy_all
      Sufia.config.after_destroy.call(generic_file.id, user) if Sufia.config.respond_to?(:after_destroy)
    end

    # Takes an optional block and executes the block if the save was successful.
    def save_characterize_and_record_committer
      save_and_record_committer { push_characterize_job }.tap do |val|
        yield if block_given? && val
      end
    end

    # Takes an optional block and executes the block if the save was successful.
    # returns false if the save was unsuccessful
    def save_and_record_committer
      save_tries = 0
      begin
        return false unless generic_file.save
      rescue RSolr::Error::Http => error
        ActiveFedora::Base.logger.warn "Sufia::GenericFile::Actor::save_and_record_committer Caught RSOLR error #{error.inspect}"
        Sufia.config.upload_logger.warn "Sufia::GenericFile::Actor::save_and_record_committer Error saving #{generic_file.title}. Caught RSOLR error #{error.inspect}"
        save_tries += 1
        # fail for good if the tries is greater than 3
        raise error if save_tries >= 3
        sleep 0.01
        retry
      rescue Ldp::Gone => error
        Sufia.config.upload_logger.warn "Sufia::GenericFile::Actor::save_and_record_committer Error saving #{generic_file.title}. Caught LDP error #{error.inspect}"
        save_tries += 1
        # fail for good if the tries is greater than 3
        raise error if save_tries >= 3
        sleep 0.01
        retry
      rescue StandardError => error
        Sufia.config.upload_logger.warn "Sufia::GenericFile::Actor::save_and_record_committer Error saving #{generic_file.title}. Caught Exception error #{error.inspect}"
        raise error
      end
      yield if block_given?
      generic_file.record_version_committer(user)
      true
    end

    def push_characterize_job
      Sufia.queue.push(CharacterizeJob.new(@generic_file.id))
    end

    class << self
      def virus_check(file)
        path = file.is_a?(String) ? file : file.path
        unless defined?(ClamAV)
          ActiveFedora::Base.logger.warn "Virus checking disabled, #{path} not checked"
          return
        end
        scan_result = ClamAV.instance.scanfile(path)
        raise Sufia::VirusFoundError, "A virus was found in #{path}: #{scan_result}" unless scan_result == 0
      end
    end

    protected

      # This method can be overridden in case there is a custom approach for visibility (e.g. embargo)
      def update_visibility(visibility)
        generic_file.visibility = visibility
      end

    private

      def remove_from_feature_works
        featured_work = FeaturedWork.find_by_generic_file_id(generic_file.id)
        featured_work.destroy unless featured_work.nil?
      end

      def acquire_lock_for(lock_key, &block)
        lock_manager.lock(lock_key, &block)
      end

      def lock_manager
        @lock_manager ||= Sufia::LockManager.new(
          Sufia.config.lock_time_to_live,
          Sufia.config.lock_retry_count,
          Sufia.config.lock_retry_delay)
      end
  end
end
