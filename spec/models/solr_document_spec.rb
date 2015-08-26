require 'spec_helper'

describe SolrDocument, type: :model do
  describe "date_uploaded" do
    before do
      subject['date_uploaded_dtsi'] = '2013-03-14T00:00:00Z'
    end
    it "is a date" do
      expect(subject.date_uploaded).to eq '03/14/2013'
    end
    it "logs parse errors" do
      expect(ActiveFedora::Base.logger).to receive(:info).with(/Unable to parse date.*/)
      subject['date_uploaded_dtsi'] = 'Test'
      subject.date_uploaded
    end
  end

  describe "create_date" do
    before do
      subject['system_create_dtsi'] = '2013-03-14T00:00:00Z'
    end
    it "is a date" do
      expect(subject.create_date).to eq '03/14/2013'
    end
    it "logs parse errors" do
      expect(ActiveFedora::Base.logger).to receive(:info).with(/Unable to parse date.*/)
      subject['system_create_dtsi'] = 'Test'
      subject.create_date
    end
  end

  describe "resource_type" do
    before do
      subject['resource_type_tesim'] = ['Image']
    end
    it "returns the resource type" do
      expect(subject.resource_type).to eq ['Image']
    end
  end

  describe '#to_param' do
    let(:id) { '1v53kn56d' }

    before do
      subject[:id] = id
    end

    it 'returns the object identifier' do
      expect(subject.to_param).to eq id
    end
  end

  describe "document types" do
    class Mimes
      include Sufia::GenericFile::MimeTypes
    end

    context "when mime-type is 'office'" do
      it "is office document" do
        Mimes.office_document_mime_types.each do |type|
          subject['mime_type_tesim'] = [type]
          expect(subject).to be_office_document
        end
      end
    end

    describe "when mime-type is 'video'" do
      it "is office" do
        Mimes.video_mime_types.each do |type|
          subject['mime_type_tesim'] = [type]
          expect(subject).to be_video
        end
      end
    end
  end
end
