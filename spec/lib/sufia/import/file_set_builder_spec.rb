require 'spec_helper'
require 'support/export_json_helper'

describe Sufia::Import::FileSetBuilder do
  let(:user) { create(:user) }
  let(:sufia6_user) { "s6user" }
  let(:sufia6_password) { "s6password" }
  let(:builder) { described_class.new(sufia6_user: sufia6_user, sufia6_password: sufia6_password) }

  let(:gf_metadata) { JSON.parse(json, symbolize_names: true) }

  let(:json) do
    generic_file_json(title: ["My Great File"],
                      date_uploaded: "2015-09-28T20:00:14.243+00:00",
                      date_modified: "2015-10-28T20:00:14.243+00:00",
                      label: "my label")
  end

  let(:permission_builder) { instance_double(Sufia::Import::PermissionBuilder) }
  let(:version_builder) { instance_double(Sufia::Import::PermissionBuilder) }
  before do
    allow(Sufia::Import::PermissionBuilder).to receive(:new).and_return(permission_builder)
    allow(Sufia::Import::VersionBuilder).to receive(:new).and_return(version_builder)
  end

  it "creates a FileSet with metadata versions and permissions" do
    expect(permission_builder).to receive(:build).with(gf_metadata[:permissions])
    expect(version_builder).to receive(:build).with(gf_metadata[:versions])
    file_set = builder.build(gf_metadata)
    expect(file_set.title).to eq(["My Great File"])
    expect(file_set.date_uploaded).to eq "2015-09-28T20:00:14.243+00:00"
    expect(file_set.date_modified).to eq "2015-10-28T20:00:14.243+00:00"
    expect(file_set.label).to eq "my label"
  end
end
