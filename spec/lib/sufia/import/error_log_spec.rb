require 'spec_helper'
require 'support/export_json_helper'

describe Sufia::Import::ErrorLog do
  let(:log_name) { described_class.file.path }
  let(:message) { "My Error\n" }
  subject { File.new(log_name, 'rb').read }

  before do
    File.delete(log_name) if File.exist?(log_name)
    described_class.error(message)
  end
  after do
    File.delete(log_name)
  end

  it { is_expected.to eq(message) }

  context "when I log multiple times" do
    let(:second_message) { "Second message\n" }
    before do
      described_class.error(second_message)
    end
    it { is_expected.to eq(message + second_message) }
  end
end
