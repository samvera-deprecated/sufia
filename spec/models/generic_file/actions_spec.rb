require 'spec_helper'

describe GenericFile do
  describe "#virus_check" do
    before do
      unless defined? ClamAV
        class ClamAV
          def self.instance
            new
          end
        end
        @stubbed_clamav = true
      end
    end
    after do
      Object.send(:remove_const, :ClamAV) if @stubbed_clamav
    end
    it "should return the results of running ClamAV scanfile method" do
      ClamAV.instance.should_receive(:scanfile).and_return(1)
      expect { Sufia::GenericFile::Actions.virus_check(File.new(fixture_path + '/world.png')) }.to raise_error(Sufia::VirusFoundError)
    end
  end
end
