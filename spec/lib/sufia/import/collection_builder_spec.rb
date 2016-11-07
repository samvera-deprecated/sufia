require 'spec_helper'
require 'support/export_json_helper'

describe Sufia::Import::CollectionBuilder do
  let(:sufia6_user) { "s6user" }
  let(:sufia6_password) { "s6password" }
  let(:builder) { described_class.new }

  let(:data) { JSON.parse(json, symbolize_names: true) }
  let(:data2) { JSON.parse(json2, symbolize_names: true) }
  let(:json) { collection_json }
  let(:json2) do
    collection_json(id: "col123",
                    title: "Mystery")
  end

  let(:permission_builder) { instance_double(Sufia::Import::PermissionBuilder) }
  before do
    allow(Sufia::Import::PermissionBuilder).to receive(:new).and_return(permission_builder)
  end

  it "creates a collection with metadata and permissions" do
    expect(permission_builder).to receive(:build).with(an_instance_of(Collection), data[:permissions])
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
      allow(permission_builder).to receive(:build).with(an_instance_of(Collection), data[:permissions])
      expect { builder.build(data) }.to raise_error RuntimeError
    end
  end
  context "when used more than once" do
    before do
      allow(permission_builder).to receive(:build)
    end
    it "creates distinct Collections" do
      coll1 = builder.build(data)
      coll2 = builder.build(data2)
      expect(coll1.title).to eq ['Fantasy']
      expect(coll1.id).to eq "2v23vt57t"
      expect(coll2.title).to eq ['Mystery']
      expect(coll2.id).to eq "col123"
    end
  end
end
