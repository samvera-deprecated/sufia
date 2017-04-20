require 'spec_helper'

describe Sufia::Import::VersionBuilder do
  let(:user) { create(:user) }
  let(:sufia6_user) { "s6user" }
  let(:sufia6_password) { "s6password" }
  let(:builder) { described_class.new({ sufia6_user: sufia6_user, sufia6_password: sufia6_password }, file_set) }
  let(:file_set) { create(:file_set, user: user) }
  subject { file_set }

  let(:version1_uri) { "http://127.0.0.1:8983/fedora/rest/dev/44/55/8d/49/44558d49x/content/fcr:versions/version1" }
  let(:version2_uri) { "http://127.0.0.1:8983/fedora/rest/dev/44/55/8d/49/44558d49x/content/fcr:versions/version2" }
  let(:versions) do
    [
      OpenStruct.new(
        "uri" => version1_uri,
        "created" => "2016-09-28T20:00:14.658Z",
        "label" => "version1"
      ),
      OpenStruct.new(
        "uri" => version2_uri,
        "created" => "2016-09-29T15:58:00.639Z",
        "label" => "version2"
      )
    ]
  end
  let(:version1) do
    file = Tempfile.new('version1')
    file.write("hello world! version1")
    file.rewind
    file
  end
  let(:version2) do
    file = Tempfile.new('version2')
    file.write("hello world! version2")
    file.rewind
    file
  end

  before do
    allow(builder).to receive(:open).with(version1_uri, http_basic_authentication: [sufia6_user, sufia6_password]).and_return(version1)
    allow(builder).to receive(:open).with(version2_uri, http_basic_authentication: [sufia6_user, sufia6_password]).and_return(version2)
    allow(CharacterizeJob).to receive(:perform_now).and_return(true)
    builder.build(versions)
  end
  after do
    version1.close
    version1.unlink
    version2.close
    version2.unlink
  end
  context "when adding permissions to the file set" do
    it "creates versions" do
      expect(file_set.original_file.versions.all.count).to eq(2)
      expect(file_set.original_file.versions.all.map(&:label)).to contain_exactly("version1", "version2")
      expect(file_set.original_file.content).to eq("hello world! version2")
      # TODO: how do we set the dates correctly...
      # expect(file_set.original_file.versions.all.map(&:created)).to contain_exactly("2016-09-28T20:00:14.658Z", "2016-09-29T15:58:00.639Z")
    end
  end
end
