require 'spec_helper'

describe Sufia::Export::VersionConverter do
  let(:file) { create :generic_file, :with_content, id: 'abc123' }
  let(:graph) { file.content.versions }
  let(:version) { graph.all.first }
  let(:uri) { version.uri }
  let(:created) { version.created }
  let(:json) { "{\"uri\":\"#{uri}\",\"created\":\"#{created}\",\"label\":\"version1\"}" }

  subject { described_class.new(graph.all.first.uri, graph).to_json }

  describe "to_json" do
    context "includes fcr:metdata" do
      subject { described_class.new(uri + '/fcr:metadata', graph).to_json }

      it { is_expected.to eq json }
    end

    context "does not include fcr:metdata" do
      subject { described_class.new(uri.gsub('/fcr:metadata', ''), graph).to_json }

      it { is_expected.to eq json }
    end
  end
end
