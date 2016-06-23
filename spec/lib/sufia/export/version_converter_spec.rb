require 'spec_helper'

describe Sufia::Export::VersionConverter do
  let(:file) { create :generic_file, :with_content, id: 'abc123' }
  let(:graph) { file.content.versions }
  let(:version) { graph.all.first }
  let(:created) { version.created }
  let(:json) { "{\"uri\":\"http://localhost:8983/fedora/rest/test/ab/c1/23/abc123/content/fcr:versions/version1\",\"created\":\"#{created}\",\"label\":\"version1\"}" }

  subject { described_class.new(graph.all.first.uri, graph).to_json }

  describe "to_json" do
    it { is_expected.to eq json }
  end
end
