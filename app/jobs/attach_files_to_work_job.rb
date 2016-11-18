# Converts UploadedFiles into FileSets and attaches them to works.
class AttachFilesToWorkJob < ActiveJob::Base
  queue_as :ingest

  before_enqueue do |job|
    log = job.arguments.last
    log.pending_job(self)
  end

  # @param [ActiveFedora::Base] the work class
  # @param [Array<UploadedFile>] an array of files to attach
  # @param [CurationConcerns::Operation] a log storing the status of the job
  def perform(work, uploaded_files, log)
    log.performing!
    uploaded_files.each do |uploaded_file|
      file_set = FileSet.new
      user = User.find_by_user_key(work.depositor)
      actor = CurationConcerns::Actors::FileSetActor.new(file_set, user)
      actor.create_metadata(work, visibility: work.visibility) do |file|
        file.permissions_attributes = work.permissions.map(&:to_hash)
      end
      child_log = CurationConcerns::Operation.create!(user: user,
                                                      operation_type: 'Attach File',
                                                      parent: log)
      attach_content(actor, uploaded_file.file, child_log)
      uploaded_file.update(file_set_uri: file_set.uri)
      child_log.success!
    end
    log.success!
  end

  private

    # @param [CurationConcerns::Actors::FileSetActor] actor
    # @param [UploadedFileUploader] file
    # @param [CurationConcerns::Operation] a log storing the status of the job
    def attach_content(actor, file, log)
      case file.file
      when CarrierWave::SanitizedFile
        actor.create_content(file.file.to_file)
      when CarrierWave::Storage::Fog::File
        import_url(actor, file, log)
      else
        error_message = "Unknown type of file #{file.class}"
        log.fail!(error_message)
        raise ArgumentError, error_message
      end
    end

    # @param [CurationConcerns::Actors::FileSetActor] actor
    # @param [UploadedFileUploader] file
    # @param [CurationConcerns::Operation] a log storing the status of the job
    def import_url(actor, file, log)
      actor.file_set.update(import_url: file.url)
      ImportUrlJob.perform_later(actor.file_set, log)
    end
end
