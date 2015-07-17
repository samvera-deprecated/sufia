module Sufia
  class RepositoryAuditService
    def self.audit_everything
      ::GenericFile.find_each do |gf|
        Sufia::GenericFileAuditService.new(gf).audit
      end
    end
  end
end
