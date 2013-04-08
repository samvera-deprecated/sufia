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

class AuditJob
  def queue_name
    :audit
  end

  PASS = 'Passing Audit Run'
  FAIL = 'Failing Audit Run'

  attr_accessor :generic_file_id, :datastream_id, :version_id

  def initialize(generic_file_id, datastream_id, version_id)
    self.generic_file_id = generic_file_id
    self.datastream_id = datastream_id
    self.version_id = version_id
  end

  def run
    generic_file = GenericFile.find(generic_file_id)
    if generic_file
      datastream = generic_file.datastreams[datastream_id]
      if datastream
        version =  datastream.versions.select { |v| v.versionID == version_id}.first
        log = GenericFile.run_audit(version)

        # look up the user for sending the message to
        login = generic_file.depositor
        if login
          user = User.find_by_user_key(login)
          logger.warn "User '#{login}' not found" unless user
          job_user = User.audituser()
          # send the user a message about the failing audit
          unless (log.pass == 1)
            message = "The audit run at #{log.created_at} for #{log.pid}:#{log.dsid}:#{log.version} was #{log.pass == 1 ? 'passing' : 'failing'}."
            subject = (log.pass == 1 ? PASS : FAIL)
            job_user.send_message(user, message, subject)
          end
        end
      else
        logger.warn "No datastream for audit!!!!! pid: #{generic_file_id} dsid: #{datastream_id}"
      end
    else
      logger.warn "No generic file for data stream audit!!!!! pid: #{generic_file_id} dsid: #{datastream_id}"
    end
  end
end
