require 'spec_helper'
require 'support/export_json_helper'

describe Sufia::Import::CollectionBuilder do
  let(:sufia6_user) { "s6user" }
  let(:sufia6_password) { "s6password" }
  let(:builder) { described_class.new }

  let(:data) { JSON.parse(json, symbolize_names: true) }
  let(:json) { collection_json }

  let(:permission_builder) { instance_double(Sufia::Import::PermissionBuilder) }
  before do
    allow(Sufia::Import::PermissionBuilder).to receive(:new).and_return(permission_builder)
  end

  it "creates a collection with metadata and permissions" do
    expect(permission_builder).to receive(:build).with(data[:permissions])
    coll = builder.build(data)
    expect(coll.id).to eq "2v23vt57t"
    expect(coll.members).to eq []
    expect(coll.title).to eq(["Fantasy"])
    expect(coll.description).to eq ["Magic and power"]
    expect(coll.creator).to eq ["Arthur"]
  end

  describe "with members that haven't been imported yet" do
    let(:json) { collection_json(member_ids: ["some_id"]) }

    it "throws a RuntimeError" do
      allow(permission_builder).to receive(:build).with(data[:permissions])
      expect { builder.build(data) }.to raise_error RuntimeError
    end
  end
end
