require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'sufia/virus_found_error'

describe GenericFile do
  describe "#virus_check" do
    let(:f) { File.new(fixture_path + '/world.png') }
    let(:generic_file) do
      GenericFile.new.tap do |gf|
        gf.apply_depositor_metadata('mjg')
        gf.save
      end
    end
    before do
      if defined? ClamAV
        ClamAV.instance.loaddb
      else
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
      generic_file.destroy
    end
    it "should return the results of running ClamAV scanfile method" do
      ClamAV.any_instance.should_receive(:scanfile).and_return(1)
      expect { Sufia::GenericFile::Actions.virus_check(f) }.to raise_error(Sufia::VirusFoundError, /virus was found/)
      generic_file.add_file(f, 'content', 'world.png')
    end
  end
end
