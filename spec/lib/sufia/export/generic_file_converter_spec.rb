require 'spec_helper'

describe Sufia::Export::GenericFileConverter do
  let(:file) { create :generic_file }
  let(:permission) { file.permissions.first }
  let(:json) { "{\"id\":\"#{file.id}\",\"label\":null,\"depositor\":\"archivist1@example.com\",\"arkivo_checksum\":null,\"relative_path\":null,\"import_url\":null,\"resource_type\":[],\"title\":[],\"creator\":[],\"contributor\":[],\"description\":[],\"tag\":[],\"rights\":[],\"publisher\":[],\"date_created\":[],\"date_uploaded\":null,\"date_modified\":null,\"subject\":[],\"language\":[],\"identifier\":[],\"based_near\":[],\"related_url\":[],\"bibliographic_citation\":[],\"source\":[],\"visibility\":\"restricted\",\"versions\":[],\"permissions\":[{\"id\":\"#{permission.id}\",\"agent\":\"http://projecthydra.org/ns/auth/person#archivist1@example.com\",\"mode\":\"http://www.w3.org/ns/auth/acl#Write\",\"access_to\":\"#{file.id}\"}]}" }
  subject { described_class.new(file) }
  describe "to_json" do
    subject { described_class.new(file).to_json }
    it { is_expected.to eq json }

    context "pretty json" do
      subject { described_class.new(file).to_json(true) }
      let(:json) { "{\n  \"id\": \"#{file.id}\",\n  \"label\": null,\n  \"depositor\": \"archivist1@example.com\",\n  \"arkivo_checksum\": null,\n  \"relative_path\": null,\n  \"import_url\": null,\n  \"resource_type\": [\n\n  ],\n  \"title\": [\n\n  ],\n  \"creator\": [\n\n  ],\n  \"contributor\": [\n\n  ],\n  \"description\": [\n\n  ],\n  \"tag\": [\n\n  ],\n  \"rights\": [\n\n  ],\n  \"publisher\": [\n\n  ],\n  \"date_created\": [\n\n  ],\n  \"date_uploaded\": null,\n  \"date_modified\": null,\n  \"subject\": [\n\n  ],\n  \"language\": [\n\n  ],\n  \"identifier\": [\n\n  ],\n  \"based_near\": [\n\n  ],\n  \"related_url\": [\n\n  ],\n  \"bibliographic_citation\": [\n\n  ],\n  \"source\": [\n\n  ],\n  \"visibility\": \"restricted\",\n  \"versions\": [\n\n  ],\n  \"permissions\": [\n    {\n      \"id\": \"#{permission.id}\",\n      \"agent\": \"http://projecthydra.org/ns/auth/person#archivist1@example.com\",\n      \"mode\": \"http://www.w3.org/ns/auth/acl#Write\",\n      \"access_to\": \"#{file.id}\"\n    }\n  ]\n}" }
      it { is_expected.to eq json }
    end

    context "file with metdata" do
      let(:file) { create :generic_file, :with_complete_metadata, :with_system_metadata }
      let(:json) { "{\"id\":\"#{file.id}\",\"label\":\"labellabel\",\"depositor\":\"archivist1@example.com\",\"arkivo_checksum\":\"checksumchecksum\",\"relative_path\":\"relpathrelpath\",\"import_url\":\"importurlimporturl\",\"resource_type\":[\"resource_typeresource_type\"],\"title\":[\"titletitle\"],\"creator\":[\"creatorcreator\"],\"contributor\":[\"contributorcontributor\"],\"description\":[\"descriptiondescription\"],\"tag\":[\"tagtag\"],\"rights\":[],\"publisher\":[\"publisherpublisher\"],\"date_created\":[\"date_createddate_created\"],\"date_uploaded\":\"2016-06-21T09:08:00.000+00:00\",\"date_modified\":\"2016-06-21T09:08:00.000+00:00\",\"subject\":[\"subjectsubject\"],\"language\":[\"languagelanguage\"],\"identifier\":[],\"based_near\":[\"based_nearbased_near\"],\"related_url\":[\"http://example.org/TheRelatedURLLink/\"],\"bibliographic_citation\":[\"bibliographic_citationbibliographic_citation\"],\"source\":[\"sourcesource\"],\"visibility\":\"restricted\",\"versions\":[],\"permissions\":[{\"id\":\"#{permission.id}\",\"agent\":\"http://projecthydra.org/ns/auth/person#archivist1@example.com\",\"mode\":\"http://www.w3.org/ns/auth/acl#Write\",\"access_to\":\"#{file.id}\"}]}" }

      it { is_expected.to eq json }
    end

    context "file with metdata and content" do
      let(:file) { create :generic_file, :with_content, :with_complete_metadata, :with_system_metadata, id: 'abc123' }
      let(:graph) { file.content.versions }
      let(:version) { graph.all.first }
      let(:created) { version.created }
      let(:json) { "{\"id\":\"#{file.id}\",\"label\":\"labellabel\",\"depositor\":\"archivist1@example.com\",\"arkivo_checksum\":\"checksumchecksum\",\"relative_path\":\"relpathrelpath\",\"import_url\":\"importurlimporturl\",\"resource_type\":[\"resource_typeresource_type\"],\"title\":[\"titletitle\"],\"creator\":[\"creatorcreator\"],\"contributor\":[\"contributorcontributor\"],\"description\":[\"descriptiondescription\"],\"tag\":[\"tagtag\"],\"rights\":[],\"publisher\":[\"publisherpublisher\"],\"date_created\":[\"date_createddate_created\"],\"date_uploaded\":\"2016-06-21T09:08:00.000+00:00\",\"date_modified\":\"2016-06-21T09:08:00.000+00:00\",\"subject\":[\"subjectsubject\"],\"language\":[\"languagelanguage\"],\"identifier\":[],\"based_near\":[\"based_nearbased_near\"],\"related_url\":[\"http://example.org/TheRelatedURLLink/\"],\"bibliographic_citation\":[\"bibliographic_citationbibliographic_citation\"],\"source\":[\"sourcesource\"],\"visibility\":\"restricted\",\"versions\":[{\"uri\":\"http://localhost:8983/fedora/rest/test/ab/c1/23/abc123/content/fcr:versions/version1\",\"created\":\"#{created}\",\"label\":\"version1\"}],\"permissions\":[{\"id\":\"#{permission.id}\",\"agent\":\"http://projecthydra.org/ns/auth/person#archivist1@example.com\",\"mode\":\"http://www.w3.org/ns/auth/acl#Write\",\"access_to\":\"#{file.id}\"}]}" }

      it { is_expected.to eq json }
    end

    context "file with write groups" do
      let(:file) { create :generic_file, read_groups: ["group1", "group2"] }
      let(:graph) { file.content.versions }
      let(:version) { graph.all.first }
      let(:created) { version.created }
      let(:permission2) { file.permissions[1] }
      let(:permission3) { file.permissions[2] }
      let(:json) { "{\"id\":\"#{file.id}\",\"label\":null,\"depositor\":\"archivist1@example.com\",\"arkivo_checksum\":null,\"relative_path\":null,\"import_url\":null,\"resource_type\":[],\"title\":[],\"creator\":[],\"contributor\":[],\"description\":[],\"tag\":[],\"rights\":[],\"publisher\":[],\"date_created\":[],\"date_uploaded\":null,\"date_modified\":null,\"subject\":[],\"language\":[],\"identifier\":[],\"based_near\":[],\"related_url\":[],\"bibliographic_citation\":[],\"source\":[],\"visibility\":\"restricted\",\"versions\":[],\"permissions\":[{\"id\":\"#{permission.id}\",\"agent\":\"http://projecthydra.org/ns/auth/group#group1\",\"mode\":\"http://www.w3.org/ns/auth/acl#Read\",\"access_to\":\"#{file.id}\"},{\"id\":\"#{permission2.id}\",\"agent\":\"http://projecthydra.org/ns/auth/group#group2\",\"mode\":\"http://www.w3.org/ns/auth/acl#Read\",\"access_to\":\"#{file.id}\"},{\"id\":\"#{permission3.id}\",\"agent\":\"http://projecthydra.org/ns/auth/person#archivist1@example.com\",\"mode\":\"http://www.w3.org/ns/auth/acl#Write\",\"access_to\":\"#{file.id}\"}]}" }

      it { is_expected.to eq json }
    end
  end
end
