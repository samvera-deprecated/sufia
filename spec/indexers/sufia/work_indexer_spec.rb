require 'spec_helper'

describe Sufia::WorkIndexer do
  let(:user) { create(:user) }
  let!(:generic_work) { create(:work_with_one_file, user: user, resource_type: ['abc123']) }
  let(:service) { described_class.new(generic_work) }

  subject { service.generate_solr_document }

  it 'indexes FileSet ids separate from other members and resource type' do
    expect(subject['file_set_ids_ssim']).to eq generic_work.member_ids
    expect(subject['resource_type_sim']).to eq generic_work.resource_type
  end
end
