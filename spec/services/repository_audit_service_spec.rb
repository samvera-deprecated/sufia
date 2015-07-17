require 'spec_helper'

describe Sufia::RepositoryAuditService do
  let(:user) { FactoryGirl.create(:user) }
  let!(:file) do
    GenericFile.create! do |file|
      file.add_file(File.open(fixture_path + '/world.png'), path: 'content', original_name: 'world.png')
      file.apply_depositor_metadata(user)
    end
  end

  describe "#audit_everything" do
    it "should audit everything" do
      # check that the method we are mocking still exists
      expect(Sufia::GenericFileAuditService.new(nil)).to respond_to(:audit)

      #make sure the audit gets called
      expect_any_instance_of(Sufia::GenericFileAuditService).to receive(:audit)
      Sufia::RepositoryAuditService.audit_everything
    end
  end
end
