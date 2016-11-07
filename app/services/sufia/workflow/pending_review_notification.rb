module Sufia
  module Workflow
    class PendingReviewNotification
      def self.send_notification(entity:,
                                 comment:,
                                 user:,
                                 recipients:)
        users_to_notify = recipients["to"] + recipients["cc"] + [user]

        id = entity.proxy_for_global_id.sub(/.*\//, '')
        title = entity.proxy_for.title.join("; ")
        comment = comment.comment.to_s || ''

        subject = "Deposit needs review"
        message = "#{title} (#{id}) was deposited by #{user.user_key} and is awaiting approval #{comment}"

        users_to_notify.uniq.each { |u| u.send_message u, message, subject }
      end
    end
  end
end
