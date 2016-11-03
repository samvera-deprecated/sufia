module CurationConcerns
  module Workflow
    class ConfirmSubmission 

      def self.test

      	byebug
      	a= 1
      	b= 2
      end
 
      def self.send_notification(params = {})
      	byebug
        
        #notifier.send_notification(entity: entity,
        ##                           comment: comment,
        ##                           user: user,
        #                           recipients: recipients(notification))

	 
        commnet = params[:comment].comment

        #these are arrays.
        #to_addresses = params[:recipients]["to"].map {|user| user.email }
      	to_users = params[:recipients]["to"]
      	#cc_addresses = params[:recipients]["to"].map {|user| user.email }
      	cc_users = cc_addresses = params[:recipients]["to"]

      	updated_at = params[:entity].updated_at
        user_email = params[:user].email

        #title and id
        id = params[:entity].proxy_for_global_id.sub(/.*\//,'')
        g = GenericWork.find id
        title = g.title

  	    message = "{id} #{}{title} has been published on #{}{updated_at} by #{}{user_email}"
        subject = "Work completed and pushished"
        
        cc_users.each {|u| u.send_message  u, message,  subject }
        to_users.each {|u| u.send_message  u, message,  subject }		



      end
    end
  end
end
