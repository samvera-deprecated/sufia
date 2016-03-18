require 'spec_helper'

describe Sufia::Statefile do
  let(:default) { '/tmp/minter-state' }
  let(:production_default) { '/var/sufia/minter-state' }

  subject { described_class.default }

  it { is_expected.to eq(default) }

  context "when in development" do
    before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development")) }
    it { is_expected.to eq(default) }
  end

  context "when in production" do
    before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production")) }
    context "with a missing default directory" do
      it "raises an error" do
        expect { subject }.to raise_error(NotImplementedError)
      end
    end
    context "with a default directory" do
      before { allow(Dir).to receive(:exist?).with(File.dirname(production_default)).and_return(true) }
      it { is_expected.to eq(production_default) }
    end
  end
end
