# A job to apply work permissions to all contained files set
#
class InheritPermissionsJob < ActiveJob::Base
  before_enqueue do |job|
    log = job.arguments.last
    log.pending_job(self)
  end

  # Perform the copy from the work to the contained filesets
  #
  # @param work containing access level and filesets
  # @param [CurationConcerns::Operation] a log storing the status of the job
  def perform(work, log)
    log.performing!
    work.file_sets.each do |file|
      child_log = CurationConcerns::Operation.create!(user: work.depositor,
                                                      operation_type: "Inherit Permissions",
                                                      parent: log)

      attribute_map = work.permissions.map(&:to_hash)

      # copy and removed access to the new access with the delete flag
      file.permissions.map(&:to_hash).each do |perm|
        unless attribute_map.include?(perm)
          perm[:_destroy] = true
          attribute_map << perm
        end
      end

      # apply the new and deleted attributes
      file.permissions_attributes = attribute_map
      if file.valid?
        child_log.success!
      else
        child_log.fail!(errors.full_messages.join(' '))
      end
      file.save!
    end
    log.success!
  end
end
