require 'spec_helper'

describe Sufia::Export::PermissionConverter do
  let(:file) { create :generic_file }
  let(:permission) { file.permissions.first }
  let(:json) { "{\"id\":\"#{permission.id}\",\"agent\":\"http://projecthydra.org/ns/auth/person#archivist1@example.com\",\"mode\":\"http://www.w3.org/ns/auth/acl#Write\",\"access_to\":\"#{file.id}\"}" }

  subject { described_class.new(permission).to_json }

  describe "to_json" do
    it { is_expected.to eq json }

    context "with group permissions" do
      let(:file) { create :generic_file, read_groups: ["group1"] }
      let(:json) { "{\"id\":\"#{permission.id}\",\"agent\":\"http://projecthydra.org/ns/auth/group#group1\",\"mode\":\"http://www.w3.org/ns/auth/acl#Read\",\"access_to\":\"#{file.id}\"}" }
      it { is_expected.to eq json }
    end
  end
end
