require 'spec_helper'

describe Sufia::Export::CollectionConverter do
  let(:user1) { FactoryGirl.build(:jill) }
  let(:collection) { create(:public_collection, title: "title1", creator: ["creator1"], description: "description1", user: user1) }
  let(:permission) { collection.permissions.first }
  let(:permission2) { collection.permissions.last }
  let(:json) { "{\"id\":\"#{collection.id}\",\"title\":\"title1\",\"description\":\"description1\",\"creator\":[\"creator1\"],\"members\":[],\"permissions\":[{\"id\":\"#{permission.id}\",\"agent\":\"http://projecthydra.org/ns/auth/group#public\",\"mode\":\"http://www.w3.org/ns/auth/acl#Read\",\"access_to\":\"#{collection.id}\"},{\"id\":\"#{permission2.id}\",\"agent\":\"http://projecthydra.org/ns/auth/person#jilluser@example.com\",\"mode\":\"http://www.w3.org/ns/auth/acl#Write\",\"access_to\":\"#{collection.id}\"}]}" }

  describe "to_json" do
    subject { described_class.new(collection).to_json }
    it { is_expected.to eq(json) }

    context "pretty to_json" do
      subject { described_class.new(collection).to_json(pretty: true) }
      let(:json) { "{\n  \"id\": \"#{collection.id}\",\n  \"title\": \"title1\",\n  \"description\": \"description1\",\n  \"creator\": [\n    \"creator1\"\n  ],\n  \"members\": [\n\n  ],\n  \"permissions\": [\n    {\n      \"id\": \"#{permission.id}\",\n      \"agent\": \"http://projecthydra.org/ns/auth/group#public\",\n      \"mode\": \"http://www.w3.org/ns/auth/acl#Read\",\n      \"access_to\": \"#{collection.id}\"\n    },\n    {\n      \"id\": \"#{permission2.id}\",\n      \"agent\": \"http://projecthydra.org/ns/auth/person#jilluser@example.com\",\n      \"mode\": \"http://www.w3.org/ns/auth/acl#Write\",\n      \"access_to\": \"#{collection.id}\"\n    }\n  ]\n}" }
      it { is_expected.to eq(json) }
    end

    context "with members" do
      let(:file1) { create(:generic_file) }
      let(:file2) { create(:generic_file) }
      before do
        collection.members = [file1, file2]
      end
      let(:json) { "{\"id\":\"#{collection.id}\",\"title\":\"title1\",\"description\":\"description1\",\"creator\":[\"creator1\"],\"members\":[\"#{file1.id}\",\"#{file2.id}\"],\"permissions\":[{\"id\":\"#{permission.id}\",\"agent\":\"http://projecthydra.org/ns/auth/group#public\",\"mode\":\"http://www.w3.org/ns/auth/acl#Read\",\"access_to\":\"#{collection.id}\"},{\"id\":\"#{permission2.id}\",\"agent\":\"http://projecthydra.org/ns/auth/person#jilluser@example.com\",\"mode\":\"http://www.w3.org/ns/auth/acl#Write\",\"access_to\":\"#{collection.id}\"}]}" }
      it { is_expected.to eq(json) }
    end

    context "with write groups" do
      subject { described_class.new(private_collection).to_json }
      let(:private_collection) { create(:private_collection, title: "title2", creator: ["creator2"], description: "description2", user: user1, edit_groups: ["group1", "group2"]) }
      let(:permission1) { private_collection.permissions.first }
      let(:permission2) { private_collection.permissions.second }
      let(:permission3) { private_collection.permissions.last }
      let(:json) { "{\"id\":\"#{private_collection.id}\",\"title\":\"title2\",\"description\":\"description2\",\"creator\":[\"creator2\"],\"members\":[],\"permissions\":[{\"id\":\"#{permission1.id}\",\"agent\":\"http://projecthydra.org/ns/auth/group#group1\",\"mode\":\"http://www.w3.org/ns/auth/acl#Write\",\"access_to\":\"#{private_collection.id}\"},{\"id\":\"#{permission2.id}\",\"agent\":\"http://projecthydra.org/ns/auth/group#group2\",\"mode\":\"http://www.w3.org/ns/auth/acl#Write\",\"access_to\":\"#{private_collection.id}\"},{\"id\":\"#{permission3.id}\",\"agent\":\"http://projecthydra.org/ns/auth/person#jilluser@example.com\",\"mode\":\"http://www.w3.org/ns/auth/acl#Write\",\"access_to\":\"#{private_collection.id}\"}]}" }
      it { is_expected.to eq json }
    end
  end
end
