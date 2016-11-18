require 'spec_helper'
require 'support/export_json_helper'

describe Sufia::Import::FileSetBuilder do
  let(:user) { create(:user) }
  let(:sufia6_user) { "s6user" }
  let(:sufia6_password) { "s6password" }
  let(:builder) { described_class.new(true) }

  let(:gf_metadata) { JSON.parse(json, symbolize_names: true) }
  let(:gf_metadata2) { JSON.parse(json2, symbolize_names: true) }

  let(:json) do
    generic_file_json(title: ["My Great File"],
                      date_uploaded: "2015-09-28T20:00:14.243+00:00",
                      date_modified: "2015-10-28T20:00:14.243+00:00",
                      label: "my label")
  end
  let(:json2) do
    generic_file_json(title: ["My Greater File"])
  end

  let(:permission_builder) { instance_double(Sufia::Import::PermissionBuilder) }
  let(:version_builder) { instance_double(Sufia::Import::VersionBuilder) }
  before do
    allow(Sufia::Import::PermissionBuilder).to receive(:new).and_return(permission_builder)
    allow(Sufia::Import::VersionBuilder).to receive(:new).and_return(version_builder)
  end

  it "creates a FileSet with metadata versions and permissions" do
    expect(permission_builder).to receive(:build).with(an_instance_of(FileSet), gf_metadata[:permissions])
    expect(version_builder).to receive(:build).with(an_instance_of(FileSet), gf_metadata[:versions])
    file_set = builder.build(gf_metadata)
    expect(file_set.title).to eq(["My Great File"])
    expect(file_set.date_uploaded.to_s).to eq "2015-09-28T20:00:14+00:00"
    expect(file_set.date_uploaded).to be_a DateTime
    expect(file_set.date_modified.to_s).to eq "2015-10-28T20:00:14+00:00"
    expect(file_set.date_modified).to be_a DateTime
    expect(file_set.label).to eq "my label"
  end

  context "when used more than once" do
    before do
      allow(permission_builder).to receive(:build)
      allow(version_builder).to receive(:build)
    end
    it "creates a distinct FileSets" do
      file_set1 = builder.build(gf_metadata)
      file_set2 = builder.build(gf_metadata2)
      expect(file_set1.title).to eq ['My Great File']
      expect(file_set2.title).to eq ['My Greater File']
    end
  end
end
