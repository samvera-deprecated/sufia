# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe FileContentDatastream do
  before do
    Sufia.queue.stub(:push).with(an_instance_of CharacterizeJob) #don't run characterization
  end
  describe "version control" do
    before do
      f = GenericFile.new
      f.add_file_datastream(File.new(fixture_path + '/world.png'), :dsid=>'content')
      f.apply_depositor_metadata('mjg36')
      f.stub(:characterize_if_changed).and_yield #don't run characterization
      f.save
      @file = f.reload
    end
    after do
      @file.delete
    end
    it "should have a list of versions with one entry" do
      @file.content.versions.count == 1
    end
    it "should return the expected version ID" do
      @file.content.versions.first.versionID.should == "content.0"
    end
    it "should support latest_version" do
      @file.content.latest_version.versionID.should == "content.0"
    end
    it "should return the same version via get_version" do
      @file.content.get_version("content.0").versionID.should == @file.content.latest_version.versionID
    end
    it "should not barf when a garbage ID is provided to get_version"  do
      @file.content.get_version("foobar").should be_nil
    end
    describe "add a version" do
      before do
        @file.add_file_datastream(File.new(fixture_path + '/world.png'), :dsid=>'content')
        @file.stub(:characterize_if_changed).and_yield #don't run characterization
        @file.save
      end
      it "should return two versions" do
        @file.content.versions.count == 2
      end
      it "should return the newer version via latest_version" do
        @file.content.versions.first.versionID.should == "content.1"
      end
      it "should return the same version via get_version" do
        @file.content.get_version("content.1").versionID.should == @file.content.latest_version.versionID
      end
    end
  end
  describe "extract_metadata" do
    before do
      @subject = FileContentDatastream.new(nil, 'content')
      @subject.stub(:pid=>'my_pid')
      @subject.stub(:dsVersionID=>'content.7')
    end
    it "should have the path" do
      @subject.send(:fits_path).should be_present
    end
    it "should return an xml document" do
      repo = mock("repo")
      repo.stub(:config=>{})
      f = File.new(fixture_path + '/world.png')
      content = mock("file")
      content.stub(:read=>f.read)
      content.stub(:rewind=>f.rewind)
      @subject.should_receive(:content).exactly(5).times.and_return(f)
      xml = @subject.extract_metadata
      doc = Nokogiri::XML.parse(xml)
      doc.root.xpath('//ns:imageWidth/text()', {'ns'=>'http://hul.harvard.edu/ois/xml/ns/fits/fits_output'}).inner_text.should == '50'
    end
    it "should return expected results when invoked via HTTP" do
      repo = mock("repo")
      repo.stub(:config=>{})
      f = ActionDispatch::Http::UploadedFile.new(:tempfile => File.new(fixture_path + '/world.png'),
                                                 :filename => 'world.png')
      content = mock("file")
      content.stub(:read=>f.read)
      content.stub(:rewind=>f.rewind)
      @subject.should_receive(:content).exactly(5).times.and_return(f)
      xml = @subject.extract_metadata
      doc = Nokogiri::XML.parse(xml)
      doc.root.xpath('//ns:identity/@mimetype', {'ns'=>'http://hul.harvard.edu/ois/xml/ns/fits/fits_output'}).first.value.should == 'image/png'
    end
  end
  describe "changed?" do
    before do
      @generic_file = GenericFile.new
      @generic_file.apply_depositor_metadata('mjg36')
      @generic_file.stub(:characterize_if_changed).and_yield #don't run characterization
    end
    after do
      @generic_file.delete
    end
    it "should only return true when the datastream has actually changed" do
      @generic_file.add_file_datastream(File.new(fixture_path + '/world.png', 'rb'), :dsid=>'content')
      @generic_file.content.changed?.should be_true
      @generic_file.save!
      @generic_file.content.changed?.should be_false

      # Add a thumbnail ds
      @generic_file.add_file_datastream(File.new(fixture_path + '/world.png'), :dsid=>'thumbnail')
      @generic_file.thumbnail.changed?.should be_true
      @generic_file.content.changed?.should be_false

      retrieved_file = @generic_file.reload
      retrieved_file.content.changed?.should be_false
    end
  end
end
