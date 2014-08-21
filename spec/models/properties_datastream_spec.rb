require 'spec_helper'

describe PropertiesDatastream do
  let(:datastream) { PropertiesDatastream.new(double('base object', uri: "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/foo", new_record?: true), 'properties') }

  before do
    datastream.import_url = 'http://example.com/somefile.txt'
  end

  describe "#import_url" do
    subject { datastream.import_url }
    it { should eq ['http://example.com/somefile.txt'] }
  end

  describe "#ng_xml" do
    subject { datastream.ng_xml.to_xml }
    it { should be_equivalent_to "<?xml version=\"1.0\"?><fields><importUrl>http://example.com/somefile.txt</importUrl></fields>" }
  end

  describe "to_solr" do
    subject { datastream.to_solr}
    it "should have import_url" do
      expect(subject['import_url_ssim']).to eq ['http://example.com/somefile.txt']
    end
  end
end
