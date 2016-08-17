require 'spec_helper'

describe Sufia::FileSetIndexer do
  let(:user) { create(:user) }
  let!(:file_set) { create(:file_set, user: user) }
  let(:service) { described_class.new(file_set) }
  let(:file) { File.open(fixture_path + '/world.png') }

  before do
    Hydra::Works::AddFileToFileSet.call(file_set, file, :original_file)
    file_set.original_file.page_count = ['1']
    file_set.original_file.file_title = ['title']
    file_set.original_file.duration = ['0:1']
    file_set.original_file.sample_rate = ['sample rate']
  end
  subject { service.generate_solr_document }

  it 'indexes audio and pdf characterization attributes' do
    expect(subject['page_count_tesim']).to eq file_set.page_count
    expect(subject['file_title_tesim']).to eq file_set.file_title
    expect(subject['duration_tesim']).to eq file_set.duration
    expect(subject['sample_rate_tesim']).to eq file_set.sample_rate
  end
end
