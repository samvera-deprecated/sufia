require 'spec_helper'

# This tests the FileSet model that is inserted into the host app by curation_concerns:models:install
# It includes the CurationConcerns::FileSetBehavior module and Sufia::FileSetBehavior
# So this test covers both the FileSetBehavior module and the generated FileSet model
describe FileSet do
  it 'has properties from characterization metadata' do
    expect(subject).to respond_to(:duration)
    expect(subject).to respond_to(:sample_rate)
  end

  describe '#indexer' do
    subject { described_class.indexer }
    it { is_expected.to eq Sufia::FileSetIndexer }
  end
end
