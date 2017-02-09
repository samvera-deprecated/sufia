class ChangeAuditLogDsidToFileId < ActiveRecord::Migration
  def change
    rename_column :checksum_audit_logs, :dsid, :file_id
    rename_index :checksum_audit_logs, 'by_pid_and_dsid', 'by_file_set_id_and_file_id'
  end
end
