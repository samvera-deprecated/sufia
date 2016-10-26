require 'spec_helper'

describe Sufia::Import::CollectionTranslator do
  let(:sufia6_user) { "s6user" }
  let(:sufia6_password) { "s6password" }
  let(:translator) { described_class.new(sufia6_user: sufia6_user, sufia6_password: sufia6_password) }

  let(:import_directory) { File.join(fixture_path, 'import') }
  let(:col_metadata) { JSON.parse(File.read(File.join(import_directory, "collection_#{collection_id}.json")), symbolize_names: true) }
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
      Sufia::Import::GenericFileTranslator.new(sufia6_user: sufia6_user, sufia6_password: sufia6_password, import_binary: false).import(import_directory, 'generic_file_')
      expect(Rails.logger).to receive(:debug).with("Importing collection_2v23vt57t.json")
      translator.import(import_directory, 'collection_')
      expect(Collection.count).to eq 1
      expect(collection.ordered_members.ids.count).to eq 1
      expect(collection.title).to include 'Fantasy'
    end

    it 'Errors when passed a nonexistent directory' do
      expect { translator.import('totallynotadirectory', 'whatever') }.to raise_error RuntimeError
    end

    it 'Errors when it tries to add a nonexistent work' do
      expect { translator.import(import_directory, 'collection_') }.to raise_error RuntimeError
    end
  end
end
