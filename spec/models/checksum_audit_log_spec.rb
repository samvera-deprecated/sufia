require 'spec_helper'

describe ChecksumAuditLog do
  before do
    allow_any_instance_of(GenericFile).to receive(:characterize).and_return(true) # stub out characterization so it does not get audited
    @f = GenericFile.new
    @f.add_file(File.open(fixture_path + '/world.png'), 'content', 'world.png')
    @f.apply_depositor_metadata('mjg36')
    @f.save!
    @version = @f.datastreams['content'].versions.first
    @version_uuid = @version.to_s.split("/").last
  end

  let(:old) { ChecksumAuditLog.create(pid: @f.pid, version: @version_uuid, pass: 1, created_at: 2.minutes.ago)}
  let(:new) { ChecksumAuditLog.create(pid: @f.pid, version: @version_uuid, pass: 0) }

  after do
    @f.delete
    ChecksumAuditLog.destroy_all
  end

  it "should return a list of logs for this datastream sorted by date descending" do
    old; new
    expect(@f.logs).to eq([new, old])
  end

  it "should prune history for a datastream" do
    old; new
    
    success1 = ChecksumAuditLog.create(pid: @f.pid, version: @version_uuid, pass: 1)
    ChecksumAuditLog.prune_history(@f.pid)
    success2 = ChecksumAuditLog.create(pid: @f.pid, version: @version_uuid, pass: 1)
    ChecksumAuditLog.prune_history(@f.pid)
    success3 = ChecksumAuditLog.create(pid: @f.pid, version: @version_uuid, pass: 1)
    ChecksumAuditLog.prune_history(@f.pid)
    expect { ChecksumAuditLog.find(success2.id) }.to raise_exception ActiveRecord::RecordNotFound
    expect { ChecksumAuditLog.find(success3.id) }.to raise_exception ActiveRecord::RecordNotFound
    
    expect(ChecksumAuditLog.find(success1.id)).not_to be_nil
    expect(@f.logs).to eq([success1, new, old])
  end
end
