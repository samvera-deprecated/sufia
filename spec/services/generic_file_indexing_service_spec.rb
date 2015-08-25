require 'spec_helper'

describe Sufia::GenericFileIndexingService do
  let(:indexer) { described_class.new(object) }
  let(:object) do
    GenericFile.create do |f|
      f.add_file(File.open(fixture_path + '/world.png'), path: 'content', original_name: 'world.png')
      f.apply_depositor_metadata('mjg36')
    end
  end

  describe '#generate_solr_document' do
    context 'when GenericFile has no content' do
      it 'does not try to index Fedora-generated SHA1 digests' do
        expect(indexer).to receive(:digest_from_content) { nil }
        indexer.generate_solr_document
      end
    end
    context 'when GenericFile has content' do
      subject { indexer.generate_solr_document }
      it 'indexes the Fedora-generated SHA1 digest' do
        expect(subject[Solrizer.solr_name('digest', :symbol)]).to eq 'urn:sha1:f794b23c0c6fe1083d0ca8b58261a078cd968967'
      end
      context 'when a subsequent version is uploaded' do
        before do
          object.add_file(File.open(fixture_path + '/xml_fits.xml'), path: 'content', original_name: 'xml_fits.xml')
          object.save!
        end
        it 'reindexes the Fedora-generated SHA1 digest' do
          expect(object.to_solr[Solrizer.solr_name('digest', :symbol)]).to eq 'urn:sha1:15fa208cb92483eca11253a56e370d96fbced075'
        end
      end
    end
  end
end
