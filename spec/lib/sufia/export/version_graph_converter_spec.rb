require 'spec_helper'

describe Sufia::Export::VersionGraphConverter do
  let(:file) { create :generic_file, :with_content, id: 'abc123' }
  let(:graph) { file.content.versions }
  let(:version1) { graph.all.first }
  let(:version2) { graph.all.last }
  let(:created1) { version1.created }
  let(:created2) { version2.created }
  let(:uri1) { version1.uri }
  let(:uri2) { version2.uri }
  let(:json) { "{\"versions\":[{\"uri\":\"#{uri1}\",\"created\":\"#{created1}\",\"label\":\"version1\"},{\"uri\":\"#{uri2}\",\"created\":\"#{created2}\",\"label\":\"version2\"}]}" }
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
