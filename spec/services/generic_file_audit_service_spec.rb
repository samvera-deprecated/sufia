require 'spec_helper'

describe Sufia::GenericFileAuditService do
  let(:f) do
    GenericFile.create do |f|
      f.add_file(File.open(fixture_path + '/world.png'), path: 'content', original_name: 'world.png')
      f.apply_depositor_metadata('mjg36')
    end
  end

  let(:service) { Sufia::GenericFileAuditService.new(f) }

  describe "#audit" do
    before do
      # force a second version
      gf = GenericFile.find(f.id)
      gf.add_file('hello two', path: 'content', original_name: 'hello2.txt')
      gf.save!
    end

    context "force an audit on a file with two versions" do
      subject { service.audit }
      specify "should return two log results" do
        expect(subject.length).to eq(2)
      end
    end
  end

  describe "#audit_file" do
    before do
      # force a second version
      gf = GenericFile.find(f.id)
      gf.add_file('hello two', path: 'content', original_name: 'hello2.txt')
      gf.save!
    end

    context "force an audit on a specific version" do
      subject { service.send(:audit_file, "content", f.content.versions.first.uri) }
      specify "should return a single log result" do
        expect(subject).to_not be_nil
      end
    end
  end

  describe "#audit_stat" do
    subject { service.send(:audit_stat) }

    describe "file loaded from fedora" do
      context "when no audits have been run" do
        it "should report that audits have not been run" do
          expect(subject).to eq "Audits have not yet been run on this file."
        end
      end

      context "when no audit is passing" do
        before do
         ChecksumAuditLog.create!(pass: 1, generic_file_id: f.id, version: f.content.versions.first.label, dsid: 'content')
        end

        it "should report that audit result" do
          expect(subject).to eq 1
        end
      end
    end

    describe "file loaded from solr" do
      let(:solr_file) { GenericFile.load_instance_from_solr(f.id) }
      let(:service) { Sufia::GenericFileAuditService.new(solr_file) }

      it "should not audit by version" do
        expect(service).not_to receive(:audit_stat_by_version)
        expect(subject).to eq "Audits have not yet been run on this file."
      end

      context "when no audit is passing" do
        before do
          ChecksumAuditLog.create!(pass: 1, generic_file_id: f.id, version: f.content.versions.first.label, dsid: 'content')
        end

        it "should report that audit result" do
          expect(service).not_to receive(:audit_stat_by_version)
          expect(subject).to eq 1
        end
      end

      context "when one audit is passing" do
        before do
          ChecksumAuditLog.create!(pass: 0, generic_file_id: f.id, version: f.content.versions.first.label, dsid: 'content')
          ChecksumAuditLog.create!(pass: 1, generic_file_id: f.id, version: f.content.versions.first.label, dsid: 'content')
        end

        it "should report that audit result" do
          expect(service).not_to receive(:audit_stat_by_version)
          expect(subject).to eq 0
        end
      end
    end
  end

  describe "#human_readable_audit_status" do
    subject do
      expect(service).to receive(:audit_stat).and_return(audit_stat)
      service.human_readable_audit_status
    end

    context "when audit_stat is 0" do
      let(:audit_stat) { 0 }
      it { is_expected.to eq 'failing' }
    end

    context "when audit_stat is 1" do
      let(:audit_stat) { 1 }
      it { is_expected.to eq 'passing' }
    end

    context "when audit_stat is something else" do
      let(:audit_stat) { 'something else' }
      it { is_expected.to eq 'something else' }
    end
  end
end
