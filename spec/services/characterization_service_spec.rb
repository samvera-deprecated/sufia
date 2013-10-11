require 'spec_helper'

describe CharacterizationService do
  describe "after job runs" do
    subject { CharacterizationService.new(generic_file) }
    let(:generic_file) {
      GenericFile.new.tap {|file|
        file.add_file(File.open(fixture_path + '/sufia/sufia_test4.pdf'), 'content', 'sufia_test4.pdf')
        file.label
      }
    }

    it "should return expected results after a save" do
      subject.call
      generic_file.file_size.should == ['218882']
      generic_file.original_checksum.should == ['5a2d761cab7c15b2b3bb3465ce64586d']

      expect(generic_file.format_label).to eq ["Portable Document Format"]
      expect(generic_file.mime_type).to eq "application/pdf"
      expect(generic_file.file_size).to eq ["218882"]
      expect(generic_file.original_checksum).to eq ["5a2d761cab7c15b2b3bb3465ce64586d"]

      generic_file.title.should include("Microsoft Word - sample.pdf.docx")
      generic_file.filename[0].should == generic_file.label
      generic_file.format_label.should == ["Portable Document Format"]
      generic_file.title.should include("Microsoft Word - sample.pdf.docx")
    end
  end
end