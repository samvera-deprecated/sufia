require 'spec_helper'

describe IngestLocalFileJob do
  context "with valid data to run" do
    let(:user) { FactoryGirl.find_or_create(:jill) }

    let(:generic_file) { create :generic_file, depositor: user }

    let(:job) { described_class.new(generic_file.id, mock_upload_directory, "world.png", user.user_key) }
    let(:mock_upload_directory) { 'spec/mock_upload_directory' }

    before do
      Dir.mkdir mock_upload_directory unless File.exist? mock_upload_directory
      FileUtils.copy(File.expand_path('../../fixtures/world.png', __FILE__), mock_upload_directory)
    end

    it "has attached a file" do
      job.run
      expect(generic_file.reload.content.size).to eq(4218)
      expect(File).not_to exist("#{mock_upload_directory}/world.png")
    end

    describe "virus checking" do
      it "runs virus check" do
        expect(Sufia::GenericFile::Actor).to receive(:virus_check).and_return(0)
        job.run
      end
      it "aborts if virus check fails" do
        allow(Sufia::GenericFile::Actor).to receive(:virus_check).and_raise(Sufia::VirusFoundError.new('A virus was found'))
        job.run
        expect(user.mailbox.inbox.first.subject).to eq("Local file ingest error")
      end
    end
  end

  context "empty job" do
    let(:job) { described_class.new(nil, nil, nil, nil) }

    it "has the correct queue name" do
      expect(job.queue_name).to eq(:ingest)
    end
  end
end
