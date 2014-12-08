require 'spec_helper'

describe FileContentDatastream, :type => :model do
  describe "#latest_version" do
    let(:version1) { "version1" }
    let(:version2) { "version2" }
    before do
      f = GenericFile.new
      f.add_file(File.open(fixture_path + '/world.png'), 'content', 'world.png')
      f.apply_depositor_metadata('mjg36')
      f.save
      @file = f.reload
    end
    context "with one version" do
      let(:latest_version) { @file.content.versions.last }
      it "should return the latest version" do
        expect(@file.content.latest_version).to eql(version1)
      end
    end
    context "with two versions" do
      before do
        @file.add_file(File.open(fixture_path + '/world.png'), 'content', 'world.png')
        @file.save
      end
      it "should return the latest version" do
        expect(@file.content.latest_version).to eql(version2)
      end
    end
  end

  describe "extract_metadata" do
    let(:datastream) { FileContentDatastream.new('foo/content') }
    let(:file) { ActionDispatch::Http::UploadedFile.new(tempfile: File.new(fixture_path + '/world.png'),
                                                 filename: 'world.png') }
    before { datastream.content = file }
    let(:document) { Nokogiri::XML.parse(datastream.extract_metadata).root }
    let(:namespace) { { 'ns'=>'http://hul.harvard.edu/ois/xml/ns/fits/fits_output' } }

    it "should return an xml document", unless: $in_travis do
      expect(document.xpath('//ns:identity/@mimetype', namespace).first.value).to eq 'image/png'
    end
  end

  describe "changed?" do
    before do
      @generic_file = GenericFile.new
      @generic_file.apply_depositor_metadata('mjg36')
    end

    it "should only return true when the datastream has actually changed" do
      @generic_file.add_file(File.open(fixture_path + '/world.png', 'rb'), 'content', 'world.png')
      expect(@generic_file.content).to be_changed
      @generic_file.save!
      expect(@generic_file.content).to_not be_changed

      # Add a thumbnail ds
      @generic_file.add_file(File.open(fixture_path + '/world.png'), 'thumbnail', 'world.png')
      expect(@generic_file.thumbnail).to be_changed
      expect(@generic_file.content).to_not be_changed

      retrieved_file = @generic_file.reload
      expect(retrieved_file.content).to_not be_changed
    end
  end
end
