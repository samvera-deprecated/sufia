require 'spec_helper'

describe Sufia::Import::GenericFileTranslator do
  let(:sufia6_user) { "s6user" }
  let(:sufia6_password) { "s6password" }
  let(:translator) { described_class.new(sufia6_user: sufia6_user, sufia6_password: sufia6_password) }

  let(:import_directory) { File.join(fixture_path, 'import') }
  let(:gf_metadata) { JSON.parse(File.read(File.join(import_directory, "generic_file_#{work_id}.json")), symbolize_names: true) }
  let(:work) { Sufia.primary_work_type.find(work_id) }
  # used to retrieve the fixture and then test that the object was created with the same id
  let(:work_id) { 'qr46r0963' }

  let(:permission_builder) { instance_double(Sufia::Import::PermissionBuilder) }
  let(:version_builder) { instance_double(Sufia::Import::VersionBuilder) }
  before do
    allow(Sufia::Import::PermissionBuilder).to receive(:new).and_return(permission_builder)
    allow(Sufia::Import::VersionBuilder).to receive(:new).and_return(version_builder)
    allow(permission_builder).to receive(:build).and_return([])
    allow(version_builder).to receive(:build).and_return([])
  end

  describe '#import' do
    it 'Creates a work with attached fileset' do
      expect(Rails.logger).to receive(:debug).with("Importing generic_file_qr46r0963.json")
      translator.import(import_directory, 'generic_file_')
      expect(Sufia.primary_work_type.count).to eq 1
      expect(FileSet.count).to eq 1
      expect(work.ordered_members.ids.count).to eq 1
      expect(work.title).to include 'Myth'
      expect(work.representative_id).to be_truthy
      expect(work.thumbnail_id).to be_truthy
    end

    it 'Errors when passed a nonexistent directory' do
      expect { translator.import('totallynotadirectory', 'whatever') }.to raise_error RuntimeError
    end
  end
end
