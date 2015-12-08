require 'spec_helper'

describe Sufia::WorkShowPresenter do
  let(:solr_document) { SolrDocument.new(work.to_solr) }
  let(:ability) { double "Ability" }
  let(:presenter) { described_class.new(solr_document, ability) }

  context "upload_set_id" do
    let(:work) { build(:generic_work) }
    it "exposes upload_set_id" do
      expect(presenter.upload_set_id).to be nil
    end
  end

  describe '#itemtype' do
    let(:work) { build(:generic_work, resource_type: type) }

    subject { presenter.itemtype }

    context 'when resource_type is Audio' do
      let(:type) { ['Audio'] }

      it {
        is_expected.to eq 'http://schema.org/AudioObject'
      }
    end

    context 'when resource_type is Conference Proceeding' do
      let(:type) { ['Conference Proceeding'] }

      it { is_expected.to eq 'http://schema.org/ScholarlyArticle' }
    end
  end
end
