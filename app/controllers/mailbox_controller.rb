# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class MailboxController < ApplicationController
  before_filter :authenticate_user!

  def index
    if user_signed_in?
      inbox = current_user.mailbox.inbox
      @messages = inbox.all
      current_user.mark_as_read @messages
    else
      @messages =[]
    end 
  end

  def delete_all     
     current_user.mailbox.inbox.each do |msg|
        delete_message(msg)
     end
     empty_trash(current_user)
     redirect_to sufia.mailbox_path
  end

  def delete
    if (current_user)
      msg = Conversation.find(params[:uid])
      if (msg.participants[0] == current_user) || (msg.participants[1] == current_user)
         delete_message(msg)
         empty_trash(msg.participants[0])
      end
   else 
      flash[:alert] = "You do not have privileges to delete the notification..."
   end
   redirect_to sufia.mailbox_path
  end

private 

  def delete_message (msg)
      msg.move_to_trash(msg.participants[0])
      msg.move_to_trash(msg.participants[1])
  end
  
  def empty_trash (user)
    user.mailbox.trash.each { |conv| conv.messages.each {|notify| notify.receipts.each { |receipt| receipt.delete}; notify.delete}; conv.delete}
  end
end
