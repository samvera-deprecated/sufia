require 'spec_helper'

describe AuditJob do
  let(:user) { FactoryGirl.create(:user) }

  let(:file) do
    GenericFile.create do |file|
      file.add_file(File.open(fixture_path + '/world.png'), path: 'content', original_name: 'world.png')
      file.apply_depositor_metadata(user)
    end
  end

  let(:job) { AuditJob.new(file.id, 'content', uri) }

  describe "#run" do
    subject { job.run }
    context "on content" do
      let(:uri) { file.content.uri }
      it { is_expected.to be true }
    end

    context "on a version of the content" do
      before { Sufia::VersioningService.create(file.content) }
      let(:uri) { Sufia::VersioningService.latest_version_of(file.content).uri }
      it { is_expected.to be true }
    end

    context "on an invalid version of the content" do
      before { Sufia::VersioningService.create(file.content) }
      let(:uri) { Sufia::VersioningService.latest_version_of(file.content).uri + 'bogus' }
      it { is_expected.to be false }
    end
  end

  describe "sending mail" do
    let(:uri) { file.content.uri }
    let(:inbox) { user.mailbox.inbox }

    before do
      allow_any_instance_of(ActiveFedora::FixityService).to receive(:check).and_return(result)
      job.run
    end

    context "when the audit passes" do
      let(:result) { true }
      it "should not send mail" do
        expect(inbox.count).to eq(0)
      end
    end
    context "when the audit fails" do
      let(:result) { false }
      it "should send failing mail" do
        expect(inbox.count).to eq(1)
        inbox.each { |msg| expect(msg.last_message.subject).to eq(AuditJob::FAIL) }
      end
    end
  end

  describe "run_audit" do
    let(:uri) { file.content.versions.first.uri }
    let(:mock_service) { double('mock fixity check service') }

    before do
      allow(ActiveFedora::FixityService).to receive(:new).and_return(mock_service)
      allow(mock_service).to receive(:check).and_return(true, false, false, true, false)
      Sufia::VersioningService.create(file.content)
      ChecksumAuditLog.create(generic_file_id: file.id, dsid: 'content', version: uri, pass: 1, created_at: 2.minutes.ago)
      ChecksumAuditLog.create(generic_file_id: file.id, dsid: 'content', version: uri, pass: 0)
    end

    it "should not prune failed audits" do
      5.times { job.send(:run_audit) }
      expect(ChecksumAuditLog.logs_for(file.id, 'content').map(&:pass)).to eq [0, 1, 0, 0, 1, 0, 1]
    end
  end
end
