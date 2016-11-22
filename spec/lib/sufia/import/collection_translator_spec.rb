require 'spec_helper'

describe Sufia::Import::CollectionTranslator do
  let(:sufia6_user) { "s6user" }
  let(:sufia6_password) { "s6password" }
  let(:translator) { described_class.new(import_dir:  import_directory) }

  let(:collection_file) { File.join(import_directory, "collection_#{collection_id}.json") }
  let(:import_directory) { File.join(fixture_path, 'import') }
  let(:col_metadata) { JSON.parse(File.read(collection_file), symbolize_names: true) }
  let(:collection) { Collection.find(collection_id) }
  # used to retrieve the fixture and then test that the object was created with the same id
  let(:collection_id) { '2v23vt57t' }

  let(:permission_builder) { instance_double(Sufia::Import::PermissionBuilder) }
  before do
    allow(Sufia::Import::PermissionBuilder).to receive(:new).and_return(permission_builder)
    allow(permission_builder).to receive(:build).and_return([])
  end

  describe '#import' do
    it 'Creates a collection with attached fileset' do
      Sufia::Import::GenericFileTranslator.new(import_dir: import_directory, import_binary: false).import
      expect(Rails.logger).to receive(:debug).with("Importing collection_2v23vt57t.json")
      translator.import
      expect(Collection.count).to eq 1
      expect(collection.ordered_members.ids.count).to eq 1
      expect(collection.title).to include 'Fantasy'
    end

    context 'when passed a nonexistent directory' do
      let(:translator) { described_class.new(import_dir: 'totallynotadirectory') }
      it 'errors' do
        expect { translator.import }.to raise_error RuntimeError
      end
    end

    it 'Errors when it tries to add a nonexistent work' do
      translator.import
      expect(File.new(Sufia::Import::Log.file.path, 'rb').read).to include("\"#{collection_file}\",\"Error getting members qr46r0963.  GenericWork must be imported before Collections\"")
    end
  end
end
