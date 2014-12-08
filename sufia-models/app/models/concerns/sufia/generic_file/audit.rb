module Sufia
  module GenericFile
    module Audit
      extend ActiveSupport::Concern

      NO_RUNS = 999

      # provides a human readable version of the audit status
      def human_readable_audit_status
        stat = audit_stat(false)
        case stat
          when 0
            'failing'
          when 1
            'passing'
          else
            stat
        end
      end
      
      # TODO: Run audits on all attached files. We're only audting "content" at tht moment
      def audit force = false
        @audit_log ||= Array.new
        @force = force
        audit_content
        return @audit_log
      end

      def audit_content
        if content.has_versions?
          audit_file_versions("content")
        else
          @audit_log << audit_file("content", content.uri)
        end
      end

      def audit_file_versions file
        attached_files[file].versions.all.each do |version|
          @audit_log << audit_file(file, version.uri,  version.label)
        end
      end

      def logs(file)
        ChecksumAuditLog.where(pid: self.id, dsid: file).order('created_at desc, id desc')
      end

      def audit!
        audit(true)
      end

      def audit_stat!
        audit_stat(true)
      end

      def audit_stat(force = false)
        logs = audit(force)
        audit_results = logs.collect { |result| result["pass"] }

        # check how many non runs we had
        non_runs = audit_results.reduce(0) { |sum, value| value == NO_RUNS ? sum += 1 : sum }
        if non_runs == 0
          result = audit_results.reduce(true) { |sum, value| sum && value }
          return result
        elsif non_runs < audit_results.length
          result = audit_results.reduce(true) { |sum, value| value == NO_RUNS ? sum : sum && value }
          return 'Some audits have not been run, but the ones run were '+ ((result)? 'passing' : 'failing') + '.'
        else
          return 'Audits have not yet been run on this file.'
        end
      end

      def audit_file(file, uri, label = nil)
        latest_audit = logs(file).first
        return latest_audit unless @force || ::GenericFile.needs_audit?(uri, latest_audit)
        Sufia.queue.push(AuditJob.new(id, file, uri))
        latest_audit ||= ChecksumAuditLog.new(pass: NO_RUNS, pid: id, dsid: file, version: label)
        latest_audit
      end


      module ClassMethods
        def audit!(version)
          ::GenericFile.audit(version, true)
        end

        def audit(version_uri, force = false)
          return { pass: true } # TODO Just skipping the audit for now
          latest_audit = self.find(version_uri).audit_each( version, force)
        end

        def needs_audit?(version, latest_audit)
          if latest_audit and latest_audit.updated_at
            days_since_last_audit = (DateTime.now - latest_audit.updated_at.to_date).to_i
            if days_since_last_audit < Sufia.config.max_days_between_audits
              return false
            end
          else
            logger.warn "***AUDIT*** problem with audit log!  Latest Audit is not nil, but updated_at is not set #{latest_audit}"  unless latest_audit.nil?
          end
          true
        end

        def audit_everything(force = false)
          ::GenericFile.find_each do |gf|
            gf.per_version do |ver|
              ::GenericFile.audit(ver, force)
            end
          end
        end

        def audit_everything!
          ::GenericFile.audit_everything(true)
        end

        def run_audit(id, path, uri)
          begin
            fixity_ok = ActiveFedora::FixityService.new(uri).check
          rescue Ldp::NotFound 
            error_msg = "resource not found"
          end

          if fixity_ok
            passing = 1
            ChecksumAuditLog.prune_history(id, path)
          else
            logger.warn "***AUDIT*** Audit failed for #{uri} #{error_msg}"
            passing = 0
          end
          check = ChecksumAuditLog.create!(pass: passing, pid: id, version: uri, dsid: path)
          check
        end
      end
    end
  end
end
