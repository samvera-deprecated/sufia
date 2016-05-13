require 'spec_helper'

describe FeaturedWorkList, type: :model do
  let(:work1) { create(:work) }
  let(:work2) { create(:work) }

  describe 'featured_works' do
    before do
      create(:featured_work, work_id: work1.id)
      create(:featured_work, work_id: work2.id)
    end

    it 'is a list of the featured work objects, each with the work\'s solr_doc' do
      expect(subject.featured_works.size).to eq 2
      solr_doc = subject.featured_works.first.work_solr_document
      expect(solr_doc).to be_kind_of SolrDocument
      expect(solr_doc.id).to eq work1.id
    end
  end

  describe 'file deleted' do
    before do
      create(:featured_work, work_id: work1.id)
      create(:featured_work, work_id: work2.id)
      work1.destroy
    end

    it 'is a list of the remaining featured work objects, each with the work\'s solr_doc' do
      expect(subject.featured_works.size).to eq 1
      solr_doc = subject.featured_works.first.work_solr_document
      expect(solr_doc).to be_kind_of SolrDocument
      expect(solr_doc.id).to eq work2.id
    end
  end

  describe '#empty?' do
    context "when there are featured works" do
      before do
        create(:featured_work, work_id: work1.id)
      end
      it { is_expected.not_to be_empty }
    end

    it { is_expected.to be_empty }
  end
end
