require 'spec_helper'

describe Sufia::Export::VersionGraphConverter do
  let(:file) { create :generic_file, :with_content, id: 'abc123' }
  let(:graph) { file.content.versions }
  let(:version1) { graph.all.first }
  let(:version2) { graph.all.last }
  let(:created1) { version1.created }
  let(:created2) { version2.created }
  let(:json) { "{\"versions\":[{\"uri\":\"http://localhost:8983/fedora/rest/test/ab/c1/23/abc123/content/fcr:versions/version1\",\"created\":\"#{created1}\",\"label\":\"version1\"},{\"uri\":\"http://localhost:8983/fedora/rest/test/ab/c1/23/abc123/content/fcr:versions/version2\",\"created\":\"#{created2}\",\"label\":\"version2\"}]}" }
  let(:user) { FactoryGirl.create(:user) }

  subject { described_class.new(graph).to_json }

  # add a second version
  before do
    file.add_file(File.open(fixture_path + '/small_file.txt'), path: 'content', original_name: 'test2.png')
    file.save
  end

  describe "to_json" do
    it { is_expected.to eq json }
  end
end
