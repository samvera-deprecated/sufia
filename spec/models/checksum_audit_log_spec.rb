require 'spec_helper'

describe ChecksumAuditLog do
  before do
    allow_any_instance_of(GenericFile).to receive(:characterize).and_return(true) # stub out characterization so it does not get audited
    @f = GenericFile.new
    @f.add_file(File.open(fixture_path + '/world.png'), 'content', 'world.png')
    @f.apply_depositor_metadata('mjg36')
    @f.save!
    @version = @f.datastreams['content'].versions.first
  end

  let(:old) { ChecksumAuditLog.create(pid: @f.pid, dsid: @version.dsid, version: @version.versionID, pass: 1, created_at: 2.minutes.ago)}
  let(:new) { ChecksumAuditLog.create(pid: @f.pid, dsid: @version.dsid, version: @version.versionID, pass: 0) }

  after do
    @f.delete
    ChecksumAuditLog.destroy_all
  end

  it "should return a list of logs for this datastream sorted by date descending" do
  skip "Skipping versions for now"
    old; new
    @f.logs(@version.dsid).should == [new, old]
  end

  it "should prune history for a datastream" do
  skip "Skipping versions for now"
    old; new
    success1 = ChecksumAuditLog.create(pid: @f.pid, dsid: @version.dsid, version: @version.versionID, pass: 1)
    ChecksumAuditLog.prune_history(@version)
    success2 = ChecksumAuditLog.create(pid: @f.pid, dsid: @version.dsid, version: @version.versionID, pass: 1)
    ChecksumAuditLog.prune_history(@version)
    success3 = ChecksumAuditLog.create(pid: @f.pid, dsid: @version.dsid, version: @version.versionID, pass: 1)
    ChecksumAuditLog.prune_history(@version)
    lambda { ChecksumAuditLog.find(success2.id)}.should raise_exception ActiveRecord::RecordNotFound
    lambda { ChecksumAuditLog.find(success3.id)}.should raise_exception ActiveRecord::RecordNotFound
    ChecksumAuditLog.find(success1.id).should_not be_nil
    @f.logs(@version.dsid).should == [success1, new, old]
  end
end
