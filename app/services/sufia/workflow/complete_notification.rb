module Sufia
  module Workflow
    class CompleteNotification
      def self.send_notification(entity:,
                                 comment:,
                                 user:,
                                 recipients:)
        id = entity.proxy_for_global_id.sub(/.*\//, '')
        title = entity.proxy_for.title.join("; ")
        comment = comment.comment.to_s || ''

        subject = "Deposit has been approved"
        message = "#{title} (#{id}) was approved by #{user.user_key}. #{comment}"

        users_to_notify = recipients["to"] + recipients["cc"] + [depositor(work_id: id)]
        users_to_notify.uniq.each { |u| u.send_message u, message, subject }
      end

      def self.depositor(work_id:)
        user_key = ActiveFedora::Base.find(work_id).depositor
        ::User.find_by(email: user_key)
      end
    end
  end
end
