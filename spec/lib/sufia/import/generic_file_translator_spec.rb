require 'spec_helper'

describe Sufia::Import::GenericFileTranslator do
  let(:sufia6_user) { "s6user" }
  let(:sufia6_password) { "s6password" }
  let(:translator) { described_class.new(import_dir: import_directory, import_binary: false) }

  let(:import_directory) { File.join(fixture_path, 'import') }
  let(:json_file_name) { File.join(import_directory, "generic_file_#{work_id}.json") }
  let(:gf_metadata) { JSON.parse(File.read(json_file_name), symbolize_names: true) }
  let(:work) { Sufia.primary_work_type.find(work_id) }
  # used to retrieve the fixture and then test that the object was created with the same id
  let(:work_id) { 'qr46r0963' }

  let(:permission_builder) { instance_double(Sufia::Import::PermissionBuilder) }
  before do
    allow(Sufia::Import::PermissionBuilder).to receive(:new).and_return(permission_builder)
    allow(permission_builder).to receive(:build).and_return([])
  end

  describe '#import' do
    it 'Creates a work with attached fileset' do
      expect(Rails.logger).to receive(:debug).with("Importing generic_file_qr46r0963.json")
      translator.import
      expect(Sufia.primary_work_type.count).to eq 1
      expect(FileSet.count).to eq 1
      expect(work.ordered_members.ids.count).to eq 1
      expect(work.title).to include 'Myth'
      expect(work.representative_id).to be_truthy
      expect(work.thumbnail_id).to be_truthy
    end

    context 'when passed a nonexistent directory' do
      let(:translator) { described_class.new(import_dir: 'totallynotadirectory') }
      it 'errors' do
        expect { translator.import }.to raise_error RuntimeError
      end
    end

    context 'when the id is already taken' do
      before do
        create(:collection, id: work_id)
        translator.import
      end

      it "Logs an error and does not process the work" do
        expect(translator).not_to receive(:build_from_json)
        expect(File.new(Sufia::Import::Log.file.path, 'rb').read).to include("\"#{json_file_name}\",\"Id exists in Fedora before import: qr46r0963\"")
      end
    end
  end
end
